import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supa.dart';

/// 12500 -> "12.500", 1.5 (dec: 1) -> "1,5"
String fmt(num v, {int dec = 0}) {
  final parts = v.toStringAsFixed(dec).split('.');
  final ip = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  return dec > 0 ? '$ip,${parts[1]}' : ip;
}

class WasteType {
  final String id, label, tip;
  final int ptsPerKg; // nilai contoh, sesuaikan dengan aturan bisnis
  const WasteType(this.id, this.label, this.tip, this.ptsPerKg);
}

const wasteTypes = <WasteType>[
  WasteType('plastik', 'Plastik', 'Bilas, keringkan, lepas tutup dan label.', 100),
  WasteType('kertas', 'Kertas', 'Jaga tetap kering dan bebas minyak.', 60),
  WasteType('kaleng', 'Kaleng', 'Kosongkan isi dan pipihkan bila bisa.', 120),
  WasteType('kaca', 'Kaca', 'Bilas dan bungkus bagian yang tajam.', 40),
  WasteType('kardus', 'Kardus', 'Lipat rata dan ikat agar rapi.', 50),
  WasteType('lain', 'Lainnya', 'Pisahkan dari sampah basah.', 30),
];

WasteType typeOf(String id) => wasteTypes.firstWhere((t) => t.id == id, orElse: () => wasteTypes.last);

class PickupRecord {
  final String label, primary, date, status;
  final double kg;
  final int points;
  const PickupRecord(this.label, this.primary, this.kg, this.points, this.date, this.status);
}

class WalletTx {
  final String title, date;
  final int amount;
  const WalletTx(this.title, this.date, this.amount);
}

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
String _tgl(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

class AppState extends ChangeNotifier {
  AppState() {
    if (!supaConfigured) _seedDemo();
  }

  bool loggedIn = false;
  String name = 'Pengguna';
  String email = '';
  String phone = '';

  int points = 0;
  double totalKg = 0;
  final double monthlyGoal = 20;
  List<double> weekly = List.filled(7, 0.0); // 7 hari terakhir, indeks 6 = hari ini
  Map<String, double> breakdown = {};
  List<PickupRecord> history = [];
  List<WalletTx> tx = [];

  // draft pickup
  Set<String> selected = {'plastik'};
  double weight = 1.0;
  String notes = '';
  String address = 'Jl. Melati No. 24, Kel. Sukamaju';
  String date = 'Hari ini';
  String slot = '15.00 - 17.00';

  int get rupiah => points * 10; // 100 poin = Rp1.000
  double get co2 => totalKg * 1.5; // estimasi kasar
  int get estPoints => selected.fold<int>(0, (s, id) => s + (weight / selected.length * typeOf(id).ptsPerKg).round());

  void _seedDemo() {
    name = 'Aluna';
    email = 'aluna@email.com';
    points = 1250;
    totalKg = 12.5;
    weekly = [1.2, 2.4, 0.8, 3.1, 1.9, 2.6, 0.5];
    breakdown = {'Plastik': 7.5, 'Kertas': 3.0, 'Kaleng': 2.0};
    history = [
      const PickupRecord('Plastik', 'plastik', 1.2, 120, '12 Nov 2026', 'Selesai'),
      const PickupRecord('Kertas, Kardus', 'kertas', 3.0, 180, '8 Nov 2026', 'Selesai'),
      const PickupRecord('Kaleng', 'kaleng', 0.8, 0, '2 Nov 2026', 'Dibatalkan'),
    ];
    tx = [
      const WalletTx('Pickup Plastik', '12 Nov 2026', 120),
      const WalletTx('Pencairan DANA', '5 Nov 2026', -500),
      const WalletTx('Pickup Kertas, Kardus', '8 Nov 2026', 180),
    ];
  }

  void resetDraft({Set<String>? types, double? kg}) {
    selected = types ?? {'plastik'};
    weight = kg ?? 1.0;
    notes = '';
    date = 'Hari ini';
    slot = '15.00 - 17.00';
  }

  void touch() => notifyListeners();

  // ------------------------------------------------------------ data dari Supabase
  Future<void> refresh() async {
    final user = db.auth.currentUser;
    if (user == null) return;
    email = user.email ?? email;
    final p = await db.from('profiles').select().eq('id', user.id).maybeSingle();
    if (p != null) {
      final n = (p['name'] as String?)?.trim();
      if (n != null && n.isNotEmpty) name = n;
      phone = (p['phone'] as String?) ?? '';
      final a = p['address'] as String?;
      if (a != null && a.isNotEmpty) address = a;
    }
    final rows = await db.from('pickups').select().order('created_at', ascending: false);
    final txRows = await db.from('wallet_tx').select().order('created_at', ascending: false);
    _rebuild(rows, txRows);
    notifyListeners();
  }

  void _rebuild(List<Map<String, dynamic>> rows, List<Map<String, dynamic>> txRows) {
    history = [
      for (final r in rows)
        PickupRecord(
          r['types'] as String,
          r['primary_type'] as String,
          (r['kg'] as num).toDouble(),
          (r['points'] as num).toInt(),
          _tgl(DateTime.parse(r['created_at'] as String).toLocal()),
          r['status'] as String,
        ),
    ];
    tx = [
      for (final r in txRows)
        WalletTx(r['title'] as String, _tgl(DateTime.parse(r['created_at'] as String).toLocal()), (r['amount'] as num).toInt()),
    ];
    points = tx.fold<int>(0, (s, t) => s + t.amount);
    totalKg = 0;
    breakdown = {};
    weekly = List.filled(7, 0.0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final r in rows) {
      if (r['status'] != 'Selesai') continue;
      final kg = (r['kg'] as num).toDouble();
      totalKg += kg;
      final labels = (r['types'] as String).split(', ');
      for (final l in labels) {
        breakdown[l] = (breakdown[l] ?? 0) + kg / labels.length;
      }
      final d = DateTime.parse(r['created_at'] as String).toLocal();
      final diff = today.difference(DateTime(d.year, d.month, d.day)).inDays;
      if (diff >= 0 && diff < 7) weekly[6 - diff] += kg;
    }
  }

  // ------------------------------------------------------------ akun
  Future<void> load() async {
    if (supaConfigured) {
      if (db.auth.currentSession != null) {
        loggedIn = true;
        try {
          await refresh();
        } catch (_) {}
      }
      notifyListeners();
      return;
    }
    final p = await SharedPreferences.getInstance();
    loggedIn = p.getBool('in') ?? false;
    name = p.getString('name') ?? name;
    email = p.getString('email') ?? email;
    notifyListeners();
  }

  Future<void> _saveLocal(String n, String mail) async {
    name = n;
    email = mail;
    loggedIn = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('in', true);
    await p.setString('name', n);
    await p.setString('email', mail);
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    if (supaConfigured) {
      await db.auth.signInWithPassword(email: email, password: password);
      loggedIn = true;
      await refresh();
      return;
    }
    var n = email.split('@').first;
    if (n.isEmpty) n = 'Pengguna';
    await _saveLocal(n[0].toUpperCase() + n.substring(1), email);
  }

  /// Mengembalikan true bila email perlu diverifikasi dulu sebelum bisa masuk.
  Future<bool> register({required String fullName, required String email, required String phone, required String password}) async {
    if (supaConfigured) {
      final r = await db.auth.signUp(email: email, password: password, data: {'name': fullName, 'phone': phone});
      if (r.session == null) return true;
      loggedIn = true;
      await refresh();
      return false;
    }
    await _saveLocal(fullName, email);
    return false;
  }

  Future<void> logout() async {
    if (supaConfigured) {
      await db.auth.signOut();
      name = 'Pengguna';
      email = '';
      points = 0;
      totalKg = 0;
      weekly = List.filled(7, 0.0);
      breakdown = {};
      history = [];
      tx = [];
    } else {
      final p = await SharedPreferences.getInstance();
      await p.setBool('in', false);
    }
    loggedIn = false;
    notifyListeners();
  }

  // ------------------------------------------------------------ pickup dan dompet
  Future<bool> completePickup() async {
    final pts = estPoints;
    final label = selected.map((e) => typeOf(e).label).join(', ');
    if (supaConfigured) {
      try {
        await db.from('pickups').insert({
          'types': label,
          'primary_type': selected.first,
          'kg': weight,
          'points': pts,
          'status': 'Selesai',
          'address': address,
          'pickup_date': date,
          'pickup_slot': slot,
          'notes': notes,
        });
        await db.from('wallet_tx').insert({'title': 'Pickup $label', 'amount': pts});
        await refresh();
        return true;
      } catch (_) {
        return false;
      }
    }
    points += pts;
    totalKg += weight;
    weekly[6] += weight;
    for (final id in selected) {
      final k = typeOf(id).label;
      breakdown[k] = (breakdown[k] ?? 0) + weight / selected.length;
    }
    history.insert(0, PickupRecord(label, selected.first, weight, pts, 'Hari ini', 'Selesai'));
    tx.insert(0, WalletTx('Pickup $label', 'Hari ini', pts));
    notifyListeners();
    return true;
  }

  Future<void> cancelPickup() async {
    final label = selected.map((e) => typeOf(e).label).join(', ');
    if (supaConfigured) {
      try {
        await db.from('pickups').insert({
          'types': label,
          'primary_type': selected.first,
          'kg': weight,
          'points': 0,
          'status': 'Dibatalkan',
          'address': address,
          'pickup_date': date,
          'pickup_slot': slot,
          'notes': notes,
        });
        await refresh();
      } catch (_) {}
      return;
    }
    history.insert(0, PickupRecord(label, selected.first, weight, 0, 'Hari ini', 'Dibatalkan'));
    notifyListeners();
  }

  /// Mencatat permintaan pencairan. Pembayaran ke e-wallet sungguhan belum terhubung.
  Future<bool> withdraw(String provider, int pts) async {
    if (supaConfigured) {
      try {
        await db.from('wallet_tx').insert({'title': 'Pencairan $provider', 'amount': -pts});
        await refresh();
        return true;
      } catch (_) {
        return false;
      }
    }
    points -= pts;
    tx.insert(0, WalletTx('Pencairan $provider', 'Hari ini', -pts));
    notifyListeners();
    return true;
  }
}

final app = AppState();
final tab = ValueNotifier<int>(0);

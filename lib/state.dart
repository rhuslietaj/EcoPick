import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

WasteType typeOf(String id) =>
    wasteTypes.firstWhere((t) => t.id == id, orElse: () => wasteTypes.last);

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

class AppState extends ChangeNotifier {
  bool loggedIn = false;
  String name = 'Aluna';
  String email = 'aluna@email.com';

  int points = 1250;
  double totalKg = 12.5;
  final double monthlyGoal = 20;
  final List<double> weekly = [1.2, 2.4, 0.8, 3.1, 1.9, 2.6, 0.5];
  final Map<String, double> breakdown = {'Plastik': 7.5, 'Kertas': 3.0, 'Kaleng': 2.0};

  final List<PickupRecord> history = [
    const PickupRecord('Plastik', 'plastik', 1.2, 120, '12 Nov 2026', 'Selesai'),
    const PickupRecord('Kertas, Kardus', 'kertas', 3.0, 180, '8 Nov 2026', 'Selesai'),
    const PickupRecord('Kaleng', 'kaleng', 0.8, 0, '2 Nov 2026', 'Dibatalkan'),
  ];
  final List<WalletTx> tx = [
    const WalletTx('Pickup Plastik', '12 Nov 2026', 120),
    const WalletTx('Pencairan DANA', '5 Nov 2026', -500),
    const WalletTx('Pickup Kertas, Kardus', '8 Nov 2026', 180),
  ];

  // draft pickup
  Set<String> selected = {'plastik'};
  double weight = 1.0;
  String notes = '';
  String address = 'Jl. Melati No. 24, Kel. Sukamaju';
  String date = 'Hari ini';
  String slot = '15.00 - 17.00';

  int get rupiah => points * 10; // 100 poin = Rp1.000
  double get co2 => totalKg * 1.5; // estimasi kasar
  int get estPoints => selected.fold<int>(
      0, (s, id) => s + (weight / selected.length * typeOf(id).ptsPerKg).round());

  void resetDraft({Set<String>? types, double? kg}) {
    selected = types ?? {'plastik'};
    weight = kg ?? 1.0;
    notes = '';
    date = 'Hari ini';
    slot = '15.00 - 17.00';
  }

  void touch() => notifyListeners();

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    loggedIn = p.getBool('in') ?? false;
    name = p.getString('name') ?? name;
    email = p.getString('email') ?? email;
    notifyListeners();
  }

  Future<void> login(String n, String mail) async {
    name = n;
    email = mail;
    loggedIn = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('in', true);
    await p.setString('name', n);
    await p.setString('email', mail);
    notifyListeners();
  }

  Future<void> logout() async {
    loggedIn = false;
    final p = await SharedPreferences.getInstance();
    await p.setBool('in', false);
    notifyListeners();
  }

  void completePickup() {
    final pts = estPoints;
    final label = selected.map((e) => typeOf(e).label).join(', ');
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
  }

  void cancelPickup() {
    final label = selected.map((e) => typeOf(e).label).join(', ');
    history.insert(0, PickupRecord(label, selected.first, weight, 0, 'Hari ini', 'Dibatalkan'));
    notifyListeners();
  }

  void withdraw(String provider, int pts) {
    points -= pts;
    tx.insert(0, WalletTx('Pencairan $provider', 'Hari ini', -pts));
    notifyListeners();
  }
}

final app = AppState();
final tab = ValueNotifier<int>(0);

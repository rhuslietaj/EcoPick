// Pemindai sampah berbasis AI. Aplikasi TIDAK menyimpan kunci AI:
// foto dikirim ke Edge Function "scan" di Supabase, dan fungsi itulah yang
// memanggil Claude memakai kunci rahasia di server.
import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException, FunctionResponse;
import 'supa.dart';

class ScanException implements Exception {
  final String message;
  ScanException(this.message);
}

class ScanResult {
  final bool detected, demo;
  final String jenis, nama, kondisi, catatan;
  final double kg;
  const ScanResult({
    required this.detected,
    required this.jenis,
    required this.nama,
    required this.kondisi,
    required this.kg,
    required this.catatan,
    this.demo = false,
  });
}

class ScanService {
  static const _ids = ['plastik', 'kertas', 'kaleng', 'kaca', 'kardus', 'lain'];

  /// Scan AI butuh Supabase terisi dan pengguna sedang login.
  static bool get available => supaConfigured && db.auth.currentSession != null;

  static String _mime(Uint8List b) {
    if (b.length > 3 && b[0] == 0x89 && b[1] == 0x50) return 'image/png';
    if (b.length > 11 && b[0] == 0x52 && b[1] == 0x49 && b[8] == 0x57) return 'image/webp';
    return 'image/jpeg';
  }

  /// Hasil contoh, dipakai bila Supabase belum disiapkan.
  static ScanResult demo() => const ScanResult(
        detected: true,
        demo: true,
        jenis: 'plastik',
        nama: 'Plastik PET (botol)',
        kondisi: 'Bersih',
        kg: .5,
        catatan: 'Ini hanya hasil contoh, bukan hasil pemindaian foto.',
      );

  static Future<ScanResult> analyze(Uint8List bytes) async {
    if (!available) {
      throw ScanException('Scan AI butuh Supabase yang sudah diisi (SUPABASE_URL dan SUPABASE_KEY) dan akun yang sedang masuk.');
    }
    late FunctionResponse res;
    try {
      res = await db.functions
          .invoke(
            'scan',
            headers: {'apikey': supaKey},
            body: {'image': base64Encode(bytes), 'mime': _mime(bytes)},
          )
          .timeout(const Duration(seconds: 60));
    } on FunctionException catch (e) {
      if (e.status == 401 || e.status == 403) {
        throw ScanException('Sesi login tidak valid. Keluar lalu masuk lagi.');
      }
      if (e.status == 404) {
        throw ScanException('Fungsi "scan" belum di-deploy di Supabase.');
      }
      throw ScanException('Server AI bermasalah (kode ${e.status}).');
    } catch (_) {
      throw ScanException('Tidak bisa terhubung ke server. Cek koneksi internet.');
    }
    try {
      final text = (res.data as Map)['text'] as String;
      final j = jsonDecode(text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1)) as Map<String, dynamic>;
      final jenis = _ids.contains(j['jenis']) ? j['jenis'] as String : 'lain';
      final kg = ((j['berat_kg'] as num?)?.toDouble() ?? 0).clamp(0.0, 50.0).toDouble();
      return ScanResult(
        detected: j['terdeteksi'] == true,
        jenis: jenis,
        nama: (j['nama'] as String?) ?? 'Sampah',
        kondisi: (j['kondisi'] as String?) ?? 'Bersih',
        kg: kg,
        catatan: (j['catatan'] as String?) ?? '',
      );
    } catch (_) {
      throw ScanException('Jawaban AI tidak bisa dibaca. Coba foto ulang.');
    }
  }
}

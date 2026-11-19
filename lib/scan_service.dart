// Pemindai sampah berbasis AI (model vision lewat Anthropic Messages API).
// Semua urusan AI ada di file ini, jadi penyedia AI mudah diganti.
//
// Jalankan dengan:
//   flutter run -d chrome --dart-define=ANTHROPIC_API_KEY=kuncimu
// Catatan: kunci yang ditanam di aplikasi bisa diekstrak orang lain. Untuk tugas/demo
// tidak masalah; untuk rilis sungguhan, panggil AI lewat server milikmu sendiri.
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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
  // 1. API AI
  static const _key = String.fromEnvironment('GEMINI_API_KEY');

  // 2. Ganti model AI (masih menggunakan AI yang tersedia)
  static const _model = 'gemini-2.5-flash';
  static const _ids = ['plastik', 'kertas', 'kaleng', 'kaca', 'kardus', 'lain'];

  static bool get hasKey => _key.isNotEmpty;

  static const _prompt = '''Kamu adalah sistem pengenal sampah daur ulang untuk aplikasi EcoPick di Indonesia.
Lihat foto dan identifikasi sampah daur ulang UTAMA di dalamnya.
Balas HANYA dengan satu objek JSON, tanpa teks lain, tanpa blok kode markdown (jangan pakai ```json ... ```), dengan kunci:
"terdeteksi": true jika ada sampah yang bisa didaur ulang, selain itu false
"jenis": salah satu dari "plastik","kertas","kaleng","kaca","kardus","lain"
"nama": nama singkat dalam bahasa Indonesia, contoh "Plastik PET (botol)"
"kondisi": "Bersih", "Kotor", atau "Basah"
"berat_kg": perkiraan total berat dalam kilogram sebagai angka desimal (tebakan terbaik dari ukuran objek)
"catatan": satu kalimat saran memilah dalam bahasa Indonesia
Jika tidak ada sampah: terdeteksi false, jenis "lain", nama "Tidak terdeteksi", kondisi "Bersih", berat_kg 0, dan jelaskan singkat di catatan.''';

  static String _mime(Uint8List b) {
    if (b.length > 3 && b[0] == 0x89 && b[1] == 0x50) return 'image/png';
    if (b.length > 11 && b[0] == 0x52 && b[1] == 0x49 && b[8] == 0x57) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  /// Hasil contoh, dipakai bila kunci API belum diisi.
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
    if (!hasKey) {
      // 3. Update pesan error untuk Gemini
      throw ScanException(
        'Kunci API belum diisi. Jalankan aplikasi dengan --dart-define=GEMINI_API_KEY=kuncimu.',
      );
    }
    late http.Response res;
    try {
      // 4. Update URL endpoint ke Gemini API
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_key',
      );

      res = await http
          .post(
            uri,
            headers: {'content-type': 'application/json'},
            // 5. Sesuaikan struktur body request dengan format Gemini API
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'inline_data': {
                        'mime_type': _mime(bytes),
                        'data': base64Encode(bytes),
                      },
                    },
                    {'text': _prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.4},
            }),
          )
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw ScanException(
        'Tidak bisa terhubung ke server AI. Cek koneksi internet.',
      );
    }

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw ScanException('Kunci API tidak valid atau tidak punya akses.');
    }
    if (res.statusCode == 429) {
      throw ScanException(
        'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
      );
    }
    if (res.statusCode != 200) {
      throw ScanException(
        'Server AI menolak permintaan (kode ${res.statusCode}).',
      );
    }

    try {
      final body =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      // 6. Sesuaikan cara mengambil teks dari struktur response Gemini
      final candidates = body['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw ScanException('Jawaban AI kosong.');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw ScanException('Format jawaban AI tidak sesuai.');
      }

      final text = parts[0]['text'] as String? ?? '';

      // Mengambil substring JSON (mengantisipasi jika model tetap menyertakan markdown ```json)
      final startIndex = text.indexOf('{');
      final endIndex = text.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1) {
        throw ScanException('Format JSON tidak ditemukan.');
      }

      final j = jsonDecode(
        text.substring(startIndex, endIndex + 1),
      ) as Map<String, dynamic>;
      final jenis = _ids.contains(j['jenis']) ? j['jenis'] as String : 'lain';
      final kg = ((j['berat_kg'] as num?)?.toDouble() ?? 0)
          .clamp(0.0, 50.0)
          .toDouble();

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

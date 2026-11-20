import 'package:supabase_flutter/supabase_flutter.dart';

// Konfigurasi default agar aplikasi langsung terhubung saat dijalankan dengan `flutter run`.
// Tetap dapat ditimpa menggunakan: flutter run --dart-define-from-file=env.json
const supaUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://rierjkiwjcvuusqynisb.supabase.co',
);
const supaKey = String.fromEnvironment(
  'SUPABASE_KEY',
  defaultValue: 'sb_publishable_W2iCONOS4Lj1tixqpEsvJA_Xn59XxuN',
);

bool get supaConfigured => supaUrl.isNotEmpty && supaKey.isNotEmpty;

Future<void> initSupabase() async {
  if (!supaConfigured) return;
  await Supabase.initialize(url: supaUrl, anonKey: supaKey);
}

SupabaseClient get db => Supabase.instance.client;

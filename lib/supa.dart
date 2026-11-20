import 'package:supabase_flutter/supabase_flutter.dart';

// Diisi lewat: flutter run --dart-define-from-file=env.json
// "Publishable key" memang dirancang untuk dipakai di aplikasi (aman bila RLS aktif).
const supaUrl = String.fromEnvironment('SUPABASE_URL');
const supaKey = String.fromEnvironment('SUPABASE_KEY');

bool get supaConfigured => supaUrl.isNotEmpty && supaKey.isNotEmpty;

Future<void> initSupabase() async {
  if (!supaConfigured) return;
  await Supabase.initialize(url: supaUrl, anonKey: supaKey);
}

SupabaseClient get db => Supabase.instance.client;

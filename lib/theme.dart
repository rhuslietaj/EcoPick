import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const forest = Color(0xFF0E3B2C);
  static const pine = Color(0xFF14573F);
  static const leaf = Color(0xFF2E9E62);
  static const mint = Color(0xFFD9F2C9);
  static const lime = Color(0xFFC8F169);
  static const sage = Color(0xFFF1F6EA);
  static const ink = Color(0xFF12241C);
  static const muted = Color(0xFF6B7F73);
  static const line = Color(0xFFDDE8D6);
  static const danger = Color(0xFFD9534F);
  static const sun = Color(0xFFFFD84D);
  static const sunSoft = Color(0xFFFFF0B3);
}

/// Gaya judul/angka besar (Fredoka, bulat dan tebal).
TextStyle disp(double size, {Color color = C.ink, double height = 1.05, double spacing = -.3}) =>
    GoogleFonts.fredoka(fontSize: size, fontWeight: FontWeight.w700, color: color, height: height, letterSpacing: spacing);

ThemeData buildTheme() {
  // Tidak memakai GoogleFonts.xxxTextTheme(): tipe TextTheme-nya bisa bentrok
  // dengan TextTheme milik Flutter pada versi google_fonts yang baru.
  final family = GoogleFonts.plusJakartaSans().fontFamily;
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.leaf, primary: C.pine),
    scaffoldBackgroundColor: C.sage,
    fontFamily: family,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.ink, displayColor: C.ink),
    splashFactory: InkSparkle.splashFactory,
  );
}

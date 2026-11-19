// Semua aset visual digambar dengan CustomPainter: tanpa emoji, tanpa file gambar.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'characters.dart';
import 'theme.dart';

void drawLeaf(Canvas cv, Offset c, double r, Paint fill, Paint vein) {
  final p = Path()
    ..moveTo(c.dx - r * .8, c.dy + r * .8)
    ..quadraticBezierTo(
      c.dx - r * 1.0,
      c.dy - r * .7,
      c.dx + r * .85,
      c.dy - r * .85,
    )
    ..quadraticBezierTo(
      c.dx + r * .95,
      c.dy + r * .75,
      c.dx - r * .8,
      c.dy + r * .8,
    )
    ..close();
  cv.drawPath(p, fill);
  cv.drawLine(
    Offset(c.dx - r * .8, c.dy + r * .8),
    Offset(c.dx + r * .35, c.dy - r * .35),
    vein,
  );
}

// ---------------------------------------------------------------- Logo
class Logo extends StatelessWidget {
  final double size;
  final Color color, accent;
  const Logo({
    super.key,
    this.size = 64,
    this.color = C.forest,
    this.accent = C.lime,
  });
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _LogoPainter(color, accent),
  );
}

class _LogoPainter extends CustomPainter {
  final Color color, accent;
  _LogoPainter(this.color, this.accent);

  void _head(Canvas cv, Offset c, double rr, double ang, double r, Paint fill) {
    final pt = c + Offset(math.cos(ang), math.sin(ang)) * rr;
    final tan = Offset(-math.sin(ang), math.cos(ang));
    final nor = Offset(math.cos(ang), math.sin(ang));
    final path = Path()
      ..moveTo(pt.dx + tan.dx * r * .26, pt.dy + tan.dy * r * .26)
      ..lineTo(pt.dx + nor.dx * r * .2, pt.dy + nor.dy * r * .2)
      ..lineTo(pt.dx - nor.dx * r * .2, pt.dy - nor.dy * r * .2)
      ..close();
    cv.drawPath(path, fill);
  }

  @override
  void paint(Canvas cv, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .14
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;
    final rect = Rect.fromCircle(center: c, radius: r * .82);
    cv.drawArc(rect, -math.pi * .08, math.pi * .78, false, stroke);
    cv.drawArc(rect, math.pi * .92, math.pi * .78, false, stroke);
    _head(cv, c, r * .82, math.pi * .70, r, fill);
    _head(cv, c, r * .82, math.pi * 1.70, r, fill);
    drawLeaf(
      cv,
      c,
      r * .34,
      Paint()..color = accent,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .05
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter o) =>
      o.color != color || o.accent != accent;
}

// ---------------------------------------------------------------- Ikon jenis sampah
class WasteIcon extends StatelessWidget {
  final String type;
  final double size;
  final Color color, detail;
  const WasteIcon(
    this.type, {
    super.key,
    this.size = 48,
    this.color = C.pine,
    this.detail = const Color(0x99FFFFFF),
  });
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _WastePainter(type, color, detail),
  );
}

class _WastePainter extends CustomPainter {
  final String type;
  final Color c, d;
  _WastePainter(this.type, this.c, this.d);

  @override
  void paint(Canvas cv, Size s) {
    final w = s.width, h = s.height;
    final f = Paint()..color = c;
    final dp = Paint()..color = d;
    final st = Paint()
      ..color = d
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .035
      ..strokeCap = StrokeCap.round;
    RRect rr(double x, double y, double ww, double hh, double r) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * w, y * h, ww * w, hh * h),
          Radius.circular(r * w),
        );

    switch (type) {
      case 'plastik':
        cv.drawRRect(rr(.40, .04, .20, .10, .03), f);
        cv.drawRRect(rr(.43, .14, .14, .14, .02), f);
        cv.drawRRect(rr(.28, .26, .44, .68, .12), f);
        cv.drawRect(Rect.fromLTWH(w * .28, h * .46, w * .44, h * .20), dp);
        break;
      case 'kertas':
        cv.save();
        cv.translate(w * .5, h * .5);
        cv.rotate(-.2);
        cv.translate(-w * .5, -h * .5);
        cv.drawRRect(
          rr(.22, .12, .46, .66, .05),
          Paint()..color = c.withValues(alpha: .45),
        );
        cv.restore();
        cv.drawRRect(rr(.30, .20, .46, .68, .05), f);
        for (var i = 0; i < 4; i++) {
          final y = h * (.36 + i * .12);
          cv.drawLine(
            Offset(w * .38, y),
            Offset(w * (i == 3 ? .56 : .68), y),
            st,
          );
        }
        break;
      case 'kaleng':
        cv.drawRRect(rr(.28, .16, .44, .70, .06), f);
        cv.drawRRect(rr(.25, .10, .50, .08, .03), f);
        cv.drawRRect(rr(.25, .84, .50, .08, .03), f);
        cv.drawRect(Rect.fromLTWH(w * .28, h * .40, w * .44, h * .24), dp);
        break;
      case 'kaca':
        cv.drawRRect(rr(.34, .06, .32, .12, .03), f);
        cv.drawRRect(rr(.38, .18, .24, .08, .02), f);
        cv.drawRRect(rr(.24, .24, .52, .70, .15), f);
        cv.drawLine(Offset(w * .34, h * .40), Offset(w * .34, h * .70), st);
        break;
      case 'kardus':
        cv.drawRRect(rr(.14, .30, .72, .56, .05), f);
        cv.drawRRect(rr(.10, .20, .80, .14, .03), f);
        cv.drawRect(Rect.fromLTWH(w * .44, h * .20, w * .12, h * .66), dp);
        break;
      default:
        for (var i = 0; i < 3; i++) {
          cv.drawCircle(Offset(w * (.26 + i * .24), h * .5), w * .09, f);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _WastePainter o) =>
      o.type != type || o.c != c || o.d != d;
}

// ---------------------------------------------------------------- Ilustrasi truk
class TruckArt extends StatelessWidget {
  final double width;
  const TruckArt({super.key, this.width = 170});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, width * .66), painter: _TruckPainter());
}

class _TruckPainter extends CustomPainter {
  @override
  void paint(Canvas cv, Size s) {
    final w = s.width, h = s.height;
    RRect rr(double x, double y, double ww, double hh, double r) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * w, y * h, ww * w, hh * h),
          Radius.circular(r * w),
        );
    cv.drawOval(
      Rect.fromLTWH(w * .04, h * .90, w * .92, h * .09),
      Paint()..color = Colors.black.withValues(alpha: .18),
    );
    cv.drawRRect(rr(.04, .12, .60, .64, .05), Paint()..color = C.mint);
    cv.drawRRect(rr(.66, .30, .30, .46, .05), Paint()..color = C.lime);
    cv.drawRRect(
      rr(.74, .37, .16, .16, .02),
      Paint()..color = C.forest.withValues(alpha: .75),
    );
    drawLeaf(
      cv,
      Offset(w * .34, h * .44),
      w * .11,
      Paint()..color = C.leaf,
      Paint()
        ..color = C.forest
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .012
        ..strokeCap = StrokeCap.round,
    );
    for (final x in [.22, .78]) {
      cv.drawCircle(
        Offset(w * x, h * .80),
        w * .085,
        Paint()..color = C.forest,
      );
      cv.drawCircle(Offset(w * x, h * .80), w * .04, Paint()..color = C.mint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ---------------------------------------------------------------- Latar blob
class BlobPainter extends CustomPainter {
  final bool dark;
  BlobPainter(this.dark);

  void _blob(Canvas cv, Offset c, double r, Color col) {
    cv.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [col, col.withValues(alpha: 0)])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  void paint(Canvas cv, Size s) {
    final w = s.width, h = s.height;
    if (dark) {
      _blob(
        cv,
        Offset(w * .95, h * .05),
        w * .65,
        C.lime.withValues(alpha: .20),
      );
      _blob(
        cv,
        Offset(w * .0, h * .85),
        w * .55,
        C.leaf.withValues(alpha: .35),
      );
    } else {
      _blob(cv, Offset(w * .98, h * .02), w * .6, C.sun.withValues(alpha: .42));
      _blob(cv, Offset(w * .0, h * .55), w * .5, C.mint.withValues(alpha: .6));
    }
  }

  @override
  bool shouldRepaint(covariant BlobPainter o) => o.dark != dark;
}

// ---------------------------------------------------------------- Peta ilustrasi
class MapPainter extends CustomPainter {
  final double t, pulse;
  final bool courier;
  MapPainter({this.t = 0, this.pulse = 0, this.courier = true});

  Path route(Size s) {
    Offset p(double x, double y) => Offset(x * s.width, y * s.height);
    final pts = [
      p(.12, .55),
      p(.12, .38),
      p(.50, .38),
      p(.50, .20),
      p(.84, .20),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  @override
  void paint(Canvas cv, Size s) {
    final w = s.width, h = s.height;
    cv.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFEAF2E0));

    final park = Paint()..color = const Color(0xFFCFE8B8);
    for (final r in [
      Rect.fromLTWH(w * .15, h * .41, w * .14, h * .11),
      Rect.fromLTWH(w * .53, h * .42, w * .14, h * .12),
      Rect.fromLTWH(w * .70, h * .23, w * .12, h * .12),
      Rect.fromLTWH(w * .02, h * .06, w * .09, h * .10),
    ]) {
      cv.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(10)), park);
    }

    final river = Path()
      ..moveTo(0, h * .74)
      ..cubicTo(w * .3, h * .62, w * .6, h * .86, w, h * .70);
    cv.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFCBE5EC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24,
    );

    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final minor = Paint()
      ..color = Colors.white.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    for (final y in [.20, .38, .55, .90]) {
      cv.drawLine(Offset(0, h * y), Offset(w, h * y), road);
    }
    for (final x in [.12, .50, .84]) {
      cv.drawLine(Offset(w * x, 0), Offset(w * x, h), road);
    }
    for (final y in [.08, .29, .47]) {
      cv.drawLine(Offset(0, h * y), Offset(w, h * y), minor);
    }
    for (final x in [.31, .68, .96]) {
      cv.drawLine(Offset(w * x, 0), Offset(w * x, h), minor);
    }

    final path = route(s);
    cv.drawPath(
      path,
      Paint()
        ..color = C.leaf.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final m = path.computeMetrics().first;
    if (courier && t > 0) {
      cv.drawPath(
        m.extractPath(0, m.length * t),
        Paint()
          ..color = C.pine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final dest = m.getTangentForOffset(m.length)!.position;
    cv.drawCircle(dest, 22, Paint()..color = C.lime.withValues(alpha: .35));
    cv.drawCircle(dest, 12, Paint()..color = C.forest);
    cv.drawCircle(dest, 8, Paint()..color = C.lime);

    final start = m.getTangentForOffset(0)!.position;
    if (!courier) {
      cv.drawCircle(start, 9, Paint()..color = C.pine);
      cv.drawCircle(start, 4, Paint()..color = Colors.white);
    } else {
      final pos = m.getTangentForOffset(m.length * t)!.position;
      cv.drawCircle(
        pos,
        20 + pulse * 22,
        Paint()..color = C.leaf.withValues(alpha: (1 - pulse) * .35),
      );
      cv.save();
      cv.translate(pos.dx - 33, pos.dy - 25);
      paintKuri(cv, const Size(66, 46));
      cv.restore();
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter o) => true;
}

// ---------------------------------------------------------------- Cincin progres
class RingPainter extends CustomPainter {
  final double progress;
  final Color bg, fg;
  RingPainter(this.progress, {required this.bg, required this.fg});
  @override
  void paint(Canvas cv, Size s) {
    final rect = Rect.fromLTWH(10, 10, s.width - 20, s.height - 20);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    cv.drawArc(rect, 0, math.pi * 2, false, p..color = bg);
    cv.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      p..color = fg,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter o) => o.progress != progress;
}

// ---------------------------------------------------------------- Tanda centang / silang
class MarkPainter extends CustomPainter {
  final double t;
  final bool ok;
  final Color bg;
  MarkPainter(this.t, this.ok, this.bg);
  @override
  void paint(Canvas cv, Size s) {
    final w = s.width, h = s.height;
    final r = w / 2 * Curves.easeOutBack.transform(math.min(1.0, t * 1.7));
    cv.drawCircle(
      s.center(Offset.zero),
      r * 1.0,
      Paint()..color = bg.withValues(alpha: .18),
    );
    cv.drawCircle(s.center(Offset.zero), r * .78, Paint()..color = bg);
    final path = Path();
    if (ok) {
      path
        ..moveTo(w * .34, h * .52)
        ..lineTo(w * .46, h * .63)
        ..lineTo(w * .67, h * .39);
    } else {
      path
        ..moveTo(w * .38, h * .38)
        ..lineTo(w * .62, h * .62)
        ..moveTo(w * .62, h * .38)
        ..lineTo(w * .38, h * .62);
    }
    final prog = ((t - .4) / .6).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final m in path.computeMetrics()) {
      cv.drawPath(m.extractPath(0, m.length * prog), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MarkPainter o) => o.t != t;
}

// ---------------------------------------------------------------- Sudut viewfinder
class BracketPainter extends CustomPainter {
  @override
  void paint(Canvas cv, Size s) {
    final p = Paint()
      ..color = C.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const l = 34.0, m = 3.0;
    final w = s.width, h = s.height;
    void corner(double x, double y, double dx, double dy) {
      cv.drawLine(Offset(x, y), Offset(x + dx * l, y), p);
      cv.drawLine(Offset(x, y), Offset(x, y + dy * l), p);
    }

    corner(m, m, 1, 1);
    corner(w - m, m, -1, 1);
    corner(m, h - m, 1, -1);
    corner(w - m, h - m, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

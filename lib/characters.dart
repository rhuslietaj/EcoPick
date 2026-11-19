//   Piko : tunas hijau bulat, maskot utama ecopick
//   Bino : tong sampah
//   Kuri : truk kurir
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'art.dart';
import 'theme.dart';

enum Kind { piko, bino }

enum Mood { happy, wink, wow, sad, cheer }

const _ink = Color(0xFF1B2B22);
const _blush = Color(0xFFFF9E8A);

// ---------------------------------------------------------------- Maskot
class Mascot extends StatefulWidget {
  final Kind kind;
  final Mood mood;
  final double size;
  final bool animate;
  const Mascot({
    super.key,
    this.kind = Kind.piko,
    this.mood = Mood.happy,
    this.size = 120,
    this.animate = true,
  });
  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) c.repeat();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (_, _) {
      final bob = math.sin(c.value * math.pi * 2) * widget.size * .022;
      return Transform.translate(
        offset: Offset(0, bob),
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _MascotPainter(widget.kind, widget.mood, c.value),
        ),
      );
    },
  );
}

class _MascotPainter extends CustomPainter {
  final Kind kind;
  final Mood mood;
  final double t;
  _MascotPainter(this.kind, this.mood, this.t);

  @override
  void paint(Canvas cv, Size s) {
    cv.save();
    cv.scale(s.width / 100);
    final blink = (t > .46 && t < .5) ? .12 : 1.0;
    final look = Offset(
      math.sin(t * math.pi * 2) * 1.6,
      mood == Mood.sad ? 1.8 : 0,
    );
    if (kind == Kind.piko) {
      _piko(cv, blink, look);
    } else {
      _bino(cv, blink, look);
    }
    cv.restore();
  }

  void _arm(Canvas cv, Offset a, Offset b, Color col) {
    cv.drawLine(
      a,
      b,
      Paint()
        ..color = col
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  void _arms(
    Canvas cv,
    double lx,
    double rx,
    double y,
    Color col,
    double sway,
  ) {
    switch (mood) {
      case Mood.cheer:
        _arm(cv, Offset(lx, y - 2), Offset(lx - 12, 34 + sway * 2), col);
        _arm(cv, Offset(rx, y - 2), Offset(rx + 12, 34 - sway * 2), col);
      case Mood.wow:
        _arm(cv, Offset(lx, y), Offset(lx - 11, y - 12), col);
        _arm(cv, Offset(rx, y), Offset(rx + 11, y - 12), col);
      case Mood.sad:
        _arm(cv, Offset(lx, y + 2), Offset(lx - 8, y + 16), col);
        _arm(cv, Offset(rx, y + 2), Offset(rx + 8, y + 16), col);
      default:
        _arm(cv, Offset(lx, y + 2), Offset(lx - 10, y + 8 + sway), col);
        _arm(cv, Offset(rx, y + 2), Offset(rx + 10, y + 8 - sway), col);
    }
  }

  void _eye(Canvas cv, Offset c, double r, double open, Offset look) {
    cv.save();
    cv.translate(c.dx, c.dy);
    cv.scale(1, open);
    cv.drawCircle(Offset.zero, r, Paint()..color = Colors.white);
    cv.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = _ink.withValues(alpha: .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    cv.drawCircle(look, r * .5, Paint()..color = _ink);
    cv.drawCircle(
      look + Offset(-r * .16, -r * .2),
      r * .17,
      Paint()..color = Colors.white,
    );
    cv.restore();
  }

  void _wink(Canvas cv, Offset c, double r) {
    cv.drawPath(
      Path()
        ..moveTo(c.dx - r * .7, c.dy + 1)
        ..quadraticBezierTo(c.dx, c.dy - r * .8, c.dx + r * .7, c.dy + 1),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _eyes(
    Canvas cv,
    Offset l,
    Offset r,
    double rad,
    double blink,
    Offset look,
  ) {
    _eye(cv, l, rad, blink, look);
    if (mood == Mood.wink) {
      _wink(cv, r, rad);
    } else {
      _eye(cv, r, rad, blink, look);
    }
  }

  void _mouth(Canvas cv, double cx, double y, double k) {
    final dark = Paint()..color = _ink;
    final tongue = Paint()..color = const Color(0xFFFF8E9E);
    switch (mood) {
      case Mood.happy:
      case Mood.wink:
        cv.drawPath(
          Path()
            ..moveTo(cx - 7 * k, y - 2 * k)
            ..quadraticBezierTo(cx, y + 11 * k, cx + 7 * k, y - 2 * k)
            ..close(),
          dark,
        );
        cv.drawOval(
          Rect.fromCenter(
            center: Offset(cx, y + 4.2 * k),
            width: 6 * k,
            height: 3.4 * k,
          ),
          tongue,
        );
      case Mood.cheer:
        cv.drawPath(
          Path()
            ..moveTo(cx - 9 * k, y - 3 * k)
            ..quadraticBezierTo(cx, y + 15 * k, cx + 9 * k, y - 3 * k)
            ..close(),
          dark,
        );
        cv.drawOval(
          Rect.fromCenter(
            center: Offset(cx, y + 6 * k),
            width: 9 * k,
            height: 5 * k,
          ),
          tongue,
        );
      case Mood.wow:
        cv.drawOval(
          Rect.fromCenter(
            center: Offset(cx, y + 3 * k),
            width: 7 * k,
            height: 10 * k,
          ),
          dark,
        );
      case Mood.sad:
        cv.drawPath(
          Path()
            ..moveTo(cx - 6 * k, y + 5 * k)
            ..quadraticBezierTo(cx, y - 2 * k, cx + 6 * k, y + 5 * k),
          Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8 * k
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  void _leaf(Canvas cv, Offset o, double len, double ang, Color col) {
    cv.save();
    cv.translate(o.dx, o.dy);
    cv.rotate(ang);
    cv.drawOval(
      Rect.fromLTWH(0, -len * .28, len, len * .56),
      Paint()..color = col,
    );
    cv.restore();
  }

  void _shadow(Canvas cv) => cv.drawOval(
    Rect.fromCenter(center: const Offset(50, 95), width: 56, height: 7),
    Paint()..color = Colors.black.withValues(alpha: .12),
  );

  void _piko(Canvas cv, double blink, Offset look) {
    const body = Color(0xFF7BCB4E),
        deep = Color(0xFF3E8E3B),
        belly = Color(0xFFDDF5C4);
    final sway = math.sin(t * math.pi * 2);
    _shadow(cv);
    cv.drawOval(
      Rect.fromCenter(center: const Offset(37, 91), width: 18, height: 10),
      Paint()..color = deep,
    );
    cv.drawOval(
      Rect.fromCenter(center: const Offset(63, 91), width: 18, height: 10),
      Paint()..color = deep,
    );
    _arms(cv, 18, 82, 60, body, sway);
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 20, 72, 72),
        const Radius.circular(34),
      ),
      Paint()..color = body,
    );
    cv.drawOval(Rect.fromLTWH(30, 54, 40, 34), Paint()..color = belly);
    cv.drawCircle(
      const Offset(25, 60),
      5.5,
      Paint()..color = _blush.withValues(alpha: .55),
    );
    cv.drawCircle(
      const Offset(75, 60),
      5.5,
      Paint()..color = _blush.withValues(alpha: .55),
    );
    cv.drawPath(
      Path()
        ..moveTo(50, 21)
        ..quadraticBezierTo(50 + sway, 13, 50, 7),
      Paint()
        ..color = deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round,
    );
    _leaf(
      cv,
      const Offset(50, 10),
      22,
      math.pi * 1.1 + sway * .08,
      const Color(0xFF9BE15D),
    );
    _leaf(
      cv,
      const Offset(50, 10),
      22,
      -math.pi * .1 - sway * .08,
      const Color(0xFFB6EE7B),
    );
    _eyes(cv, const Offset(38, 45), const Offset(62, 45), 11.5, blink, look);
    _mouth(cv, 50, 64, 1);
  }

  void _bino(Canvas cv, double blink, Offset look) {
    const body = Color(0xFF2E9E62), lid = Color(0xFFC8F169);
    final sway = math.sin(t * math.pi * 2);
    _shadow(cv);
    _arms(cv, 18, 82, 60, body, sway);
    final path = Path()
      ..moveTo(18, 38)
      ..lineTo(82, 38)
      ..lineTo(76, 90)
      ..lineTo(24, 90)
      ..close();
    cv.drawPath(path, Paint()..color = body);
    cv.drawPath(
      path,
      Paint()
        ..color = body
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeJoin = StrokeJoin.round,
    );
    final arc = Paint()
      ..color = Colors.white.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final r = Rect.fromCircle(center: const Offset(50, 80), radius: 6);
    cv.drawArc(r, .2, 2.4, false, arc);
    cv.drawArc(r, math.pi + .2, 2.4, false, arc);
    cv.drawCircle(
      const Offset(28, 66),
      4.5,
      Paint()..color = _blush.withValues(alpha: .5),
    );
    cv.drawCircle(
      const Offset(72, 66),
      4.5,
      Paint()..color = _blush.withValues(alpha: .5),
    );
    final open = mood == Mood.cheer ? -.24 : (mood == Mood.wow ? -.12 : 0.0);
    cv.save();
    cv.translate(84, 32);
    cv.rotate(open);
    cv.translate(-84, -32);
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 24, 80, 13),
        const Radius.circular(6.5),
      ),
      Paint()..color = lid,
    );
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(38, 16, 24, 9),
        const Radius.circular(4.5),
      ),
      Paint()..color = lid,
    );
    cv.restore();
    _eyes(cv, const Offset(39, 54), const Offset(61, 54), 9, blink, look);
    _mouth(cv, 50, 67, .8);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter o) =>
      o.t != t || o.mood != mood || o.kind != kind;
}

// ---------------------------------------------------------------- Kuri (truk kurir)
void paintKuri(Canvas cv, Size s) {
  cv.save();
  cv.scale(s.width / 100);
  cv.drawOval(
    Rect.fromCenter(center: const Offset(50, 66), width: 84, height: 6),
    Paint()..color = Colors.black.withValues(alpha: .15),
  );
  cv.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 8, 56, 44),
      const Radius.circular(7),
    ),
    Paint()..color = C.muted,
  );
  drawLeaf(
    cv,
    const Offset(32, 30),
    10,
    Paint()..color = C.leaf,
    Paint()
      ..color = C.forest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round,
  );
  cv.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(56, 20, 40, 32),
      const Radius.circular(9),
    ),
    Paint()..color = C.lime,
  );
  cv.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(62, 25, 28, 16),
      const Radius.circular(6),
    ),
    Paint()..color = C.forest,
  );
  for (final x in [70.0, 82.0]) {
    cv.drawCircle(Offset(x, 33), 5.4, Paint()..color = Colors.white);
    cv.drawCircle(Offset(x + 1, 33.5), 2.6, Paint()..color = _ink);
  }
  cv.drawPath(
    Path()
      ..moveTo(71, 46)
      ..quadraticBezierTo(76, 50, 81, 46),
    Paint()
      ..color = C.forest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round,
  );
  cv.drawCircle(const Offset(96, 44), 2.6, Paint()..color = C.sun);
  for (final x in [22.0, 78.0]) {
    cv.drawCircle(Offset(x, 54), 8.5, Paint()..color = C.forest);
    cv.drawCircle(Offset(x, 54), 4, Paint()..color = C.mint);
  }
  cv.restore();
}

class KuriArt extends StatelessWidget {
  final double width;
  const KuriArt({super.key, this.width = 100});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, width * .7), painter: _KuriPainter());
}

class _KuriPainter extends CustomPainter {
  @override
  void paint(Canvas cv, Size s) => paintKuri(cv, s);
  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ---------------------------------------------------------------- Dekorasi
class Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  const Sparkle({super.key, this.size = 24, this.color = C.sun});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SparklePainter(color));
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);
  @override
  void paint(Canvas cv, Size s) {
    final w = s.width, c = s.width / 2;
    final p = Path()
      ..moveTo(c, 0)
      ..quadraticBezierTo(c, c, w, c)
      ..quadraticBezierTo(c, c, c, w)
      ..quadraticBezierTo(c, c, 0, c)
      ..quadraticBezierTo(c, c, c, 0)
      ..close();
    cv.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter o) => o.color != color;
}

class Coin extends StatelessWidget {
  final double size;
  const Coin({super.key, this.size = 36});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _CoinPainter());
}

class _CoinPainter extends CustomPainter {
  @override
  void paint(Canvas cv, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    cv.drawCircle(
      c.translate(0, r * .07),
      r,
      Paint()..color = const Color(0xFFE0A100),
    );
    cv.drawCircle(c, r * .96, Paint()..color = C.sun);
    cv.drawCircle(
      c,
      r * .72,
      Paint()
        ..color = const Color(0xFFFFE680)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .1,
    );
    drawLeaf(
      cv,
      c,
      r * .34,
      Paint()..color = const Color(0xFFE0A100),
      Paint()
        ..color = C.sun
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .06
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ---------------------------------------------------------------- Balon bicara
class SpeechRow extends StatelessWidget {
  final String text;
  final Kind kind;
  final Mood mood;
  const SpeechRow({
    super.key,
    required this.text,
    this.kind = Kind.piko,
    this.mood = Mood.happy,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Mascot(kind: kind, mood: mood, size: 70),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomRight: Radius.circular(22),
                bottomLeft: Radius.circular(6),
              ),
              border: Border.all(color: C.line),
              boxShadow: [
                BoxShadow(
                  color: C.forest.withValues(alpha: .06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: disp(15, color: C.pine, height: 1.2, spacing: 0),
            ),
          ),
        ),
      ],
    ),
  );
}

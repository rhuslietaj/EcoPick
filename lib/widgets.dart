import 'package:material_ui/material_ui.dart';

import 'art.dart';
import 'theme.dart';

Route<T> fade<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 380),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, a, _, child) {
    final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: c,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .03),
          end: Offset.zero,
        ).animate(c),
        child: child,
      ),
    );
  },
);

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.forest,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
}

class Backdrop extends StatelessWidget {
  final Widget child;
  final bool dark;
  const Backdrop({super.key, required this.child, this.dark = false});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [C.forest, C.pine]
                  : const [Color(0xFFFFFBEA), C.sage, Color(0xFFDDF0C9)],
            ),
          ),
        ),
      ),
      Positioned.fill(child: CustomPaint(painter: BlobPainter(dark))),
      Positioned.fill(child: child),
    ],
  );
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: C.line.withValues(alpha: .7)),
      boxShadow: [
        BoxShadow(
          color: C.forest.withValues(alpha: .07),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

enum PStyle { filled, lime, ghost, danger }

class PButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final PStyle style;
  final bool compact;
  const PButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.style = PStyle.filled,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    BorderSide side = BorderSide.none;
    switch (style) {
      case PStyle.filled:
        bg = C.forest;
        fg = Colors.white;
      case PStyle.lime:
        bg = C.lime;
        fg = C.forest;
      case PStyle.ghost:
        bg = Colors.white;
        fg = C.forest;
        side = const BorderSide(color: C.line, width: 1.4);
      case PStyle.danger:
        bg = Colors.white;
        fg = C.danger;
        side = BorderSide(color: C.danger.withValues(alpha: .4), width: 1.4);
    }
    final btn = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        side: side,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        child: Container(
          height: compact ? 46 : 56,
          padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 12),
          alignment: compact ? null : Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: disp(compact ? 15 : 17, color: fg, spacing: 0),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: fg, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
    return compact ? btn : SizedBox(width: double.infinity, child: btn);
  }
}

class AppField extends StatelessWidget {
  final String label;
  final String? hint, initial;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboard;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  const AppField(
    this.label, {
    super.key,
    required this.icon,
    this.hint,
    this.initial,
    this.obscure = false,
    this.controller,
    this.keyboard,
    this.maxLines = 1,
    this.onChanged,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: c, width: w),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: C.pine,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initial : null,
          obscureText: obscure,
          keyboardType: keyboard,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: C.muted,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: C.leaf, size: 21),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            border: b(C.line),
            enabledBorder: b(C.line),
            focusedBorder: b(C.leaf, 1.8),
          ),
        ),
      ],
    );
  }
}

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;
  const CircleBtn(this.icon, this.onTap, {super.key, this.dark = false});
  @override
  Widget build(BuildContext context) => Material(
    color: dark ? Colors.white.withValues(alpha: .14) : Colors.white,
    shape: const CircleBorder(),
    elevation: 0,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 18, color: dark ? Colors.white : C.forest),
      ),
    ),
  );
}

class TopBar extends StatelessWidget {
  final String title;
  final bool dark, back;
  const TopBar(this.title, {super.key, this.dark = false, this.back = true});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    child: Row(
      children: [
        back
            ? CircleBtn(
                Icons.arrow_back_ios_new_rounded,
                () => Navigator.maybePop(context),
                dark: dark,
              )
            : const SizedBox(width: 44),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: disp(19, color: dark ? Colors.white : C.ink),
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    ),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const Pill(this.text, {super.key, this.bg = C.mint, this.fg = C.pine});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 11.5, fontWeight: FontWeight.w800),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 14, left: 2),
    child: Text(text, style: disp(22)),
  );
}

class ChoiceTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChoiceTag(this.label, this.selected, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? C.forest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? C.forest : C.line, width: 1.3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: selected ? C.lime : C.ink,
        ),
      ),
    ),
  );
}

class Reveal extends StatefulWidget {
  final Widget child;
  final int delay;
  const Reveal({super.key, required this.child, this.delay = 0});
  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) c.forward();
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .08),
          end: Offset.zero,
        ).animate(curve),
        child: widget.child,
      ),
    );
  }
}

/// Judul besar dengan satu bagian diberi warna aksen.
class Headline extends StatelessWidget {
  final String text, hi;
  final double size;
  final Color color, accent;
  final TextAlign align;
  const Headline(
    this.text, {
    super.key,
    required this.hi,
    this.size = 34,
    this.color = C.ink,
    this.accent = C.leaf,
    this.align = TextAlign.start,
  });
  @override
  Widget build(BuildContext context) {
    final i = text.indexOf(hi);
    if (i < 0) {
      return Text(
        text,
        textAlign: align,
        style: disp(size, color: color),
      );
    }
    return RichText(
      textAlign: align,
      text: TextSpan(
        style: disp(size, color: color),
        children: [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
            text: hi,
            style: TextStyle(color: accent),
          ),
          TextSpan(text: text.substring(i + hi.length)),
        ],
      ),
    );
  }
}

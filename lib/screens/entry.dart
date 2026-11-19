import 'package:material_ui/material_ui.dart';

import '../art.dart';
import '../characters.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home.dart';

// ======================================================== Splash
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await app.load();
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      fade(app.loggedIn ? const HomeShell() : const AuthScreen()),
    );
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Backdrop(
      dark: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: c,
                curve: const Interval(0, .5, curve: Curves.easeOutBack),
              ),
              child: SizedBox(
                width: 240,
                height: 196,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      left: 16,
                      top: 22,
                      child: Sparkle(size: 24, color: C.lime),
                    ),
                    const Positioned(
                      right: 12,
                      top: 8,
                      child: Sparkle(size: 34, color: C.sun),
                    ),
                    const Positioned(
                      right: 34,
                      bottom: 34,
                      child: Sparkle(size: 16, color: Colors.white54),
                    ),
                    const Mascot(mood: Mood.cheer, size: 180),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: c,
                curve: const Interval(.3, .7),
              ),
              child: Column(
                children: [
                  Text(
                    'EcoPick',
                    style: disp(50, color: Colors.white, spacing: .5),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilah di rumah. Kami jemput.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            SizedBox(
              width: 140,
              child: AnimatedBuilder(
                animation: c,
                builder: (_, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: c.value,
                    minHeight: 4,
                    backgroundColor: Colors.white12,
                    color: C.lime,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ======================================================== Login / Register
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool reg = false, hide = true;
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final pass = TextEditingController();
  final pass2 = TextEditingController();

  @override
  void dispose() {
    for (final c in [name, email, phone, pass, pass2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty ||
        pass.text.isEmpty ||
        (reg && name.text.trim().isEmpty)) {
      toast(context, 'Lengkapi data terlebih dahulu');
      return;
    }
    if (reg && pass.text != pass2.text) {
      toast(context, 'Konfirmasi kata sandi tidak sama');
      return;
    }
    // TODO: ganti dengan panggilan API autentikasi (package http)
    var n = reg ? name.text.trim() : email.text.trim().split('@').first;
    if (n.isEmpty) n = 'Pengguna';
    n = n[0].toUpperCase() + n.substring(1);
    await app.login(n, email.text.trim());
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      fade(const HomeShell()),
      (r) => false,
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? C.forest : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: active ? C.lime : C.muted,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 310,
          child: Backdrop(
            dark: true,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Logo(size: 40, color: Colors.white, accent: C.lime),
                        SizedBox(width: 12),
                        Text(
                          'EcoPick',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        reg
                            ? 'Buat akun\nbaru kamu'
                            : 'Selamat datang\nkembali',
                        key: ValueKey(reg),
                        style: disp(36, color: Colors.white, height: 1.02),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ubah sampah terpilah jadi poin.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 18,
          top: 150,
          child: Mascot(size: 112, mood: reg ? Mood.wink : Mood.happy),
        ),
        Positioned(
          top: 244,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: C.sage,
              borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
              child: Column(
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: C.line),
                    ),
                    child: Row(
                      children: [
                        _seg('Masuk', !reg, () => setState(() => reg = false)),
                        _seg('Daftar', reg, () => setState(() => reg = true)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      children: [
                        if (reg) ...[
                          AppField(
                            'Nama lengkap',
                            icon: Icons.person_outline_rounded,
                            hint: 'Nama kamu',
                            controller: name,
                          ),
                          const SizedBox(height: 16),
                        ],
                        AppField(
                          'Email',
                          icon: Icons.mail_outline_rounded,
                          hint: 'nama@email.com',
                          controller: email,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        if (reg) ...[
                          AppField(
                            'Nomor telepon',
                            icon: Icons.phone_outlined,
                            hint: '08xxxxxxxxxx',
                            controller: phone,
                            keyboard: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                        ],
                        AppField(
                          'Kata sandi',
                          icon: Icons.lock_outline_rounded,
                          hint: 'Minimal 6 karakter',
                          controller: pass,
                          obscure: hide,
                          suffix: IconButton(
                            icon: Icon(
                              hide
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: C.muted,
                            ),
                            onPressed: () => setState(() => hide = !hide),
                          ),
                        ),
                        if (reg) ...[
                          const SizedBox(height: 16),
                          AppField(
                            'Konfirmasi kata sandi',
                            icon: Icons.lock_outline_rounded,
                            hint: 'Ulangi kata sandi',
                            controller: pass2,
                            obscure: hide,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!reg)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            toast(context, 'Fitur ini belum tersedia di demo'),
                        child: const Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            color: C.leaf,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 14),
                  PButton(
                    reg ? 'Daftar Sekarang' : 'Masuk',
                    icon: Icons.arrow_forward_rounded,
                    onTap: submit,
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: C.line)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            color: C.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: C.line)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PButton(
                    'Lanjut dengan Google',
                    style: PStyle.ghost,
                    icon: Icons.g_mobiledata_rounded,
                    onTap: () =>
                        toast(context, 'Fitur ini belum tersedia di demo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

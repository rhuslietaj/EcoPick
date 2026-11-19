import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:camera/camera.dart';

import '../art.dart';
import '../characters.dart';
import '../scan_service.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

// ======================================================== Scan sampah (kamera langsung + AI)
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  CameraController? cam;
  bool camLoading = true;
  String? camError;
  Uint8List? img;
  bool scanning = false;
  ScanResult? result;
  String? error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    c.dispose();
    cam?.dispose();
    super.dispose();
  }

  Mood get _mood => scanning
      ? Mood.wow
      : (result != null
            ? (result!.detected ? Mood.cheer : Mood.sad)
            : ((error != null || camError != null) ? Mood.sad : Mood.happy));

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw StateError('tidak ada kamera');
      final d = cams.firstWhere(
        (x) => x.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final ctrl = CameraController(
        d,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        cam = ctrl;
        camLoading = false;
        camError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        camLoading = false;
        camError = 'Kamera tidak bisa dibuka. Izinkan akses kamera di browser atau pengaturan HP, lalu coba lagi.';
      });
    }
  }

  void _retryCamera() {
    setState(() {
      camLoading = true;
      camError = null;
    });
    _initCamera();
  }

  Future<void> _shoot() async {
    final ctrl = cam;
    if (ctrl == null || !ctrl.value.isInitialized || scanning) return;
    try {
      final f = await ctrl.takePicture();
      final bytes = await f.readAsBytes();
      if (!mounted) return;
      setState(() => img = bytes);
      await _analyze(bytes);
    } catch (_) {
      if (mounted) setState(() => error = 'Gagal mengambil foto. Coba lagi.');
    }
  }

  Future<void> _analyze(Uint8List bytes) async {
    setState(() {
      scanning = true;
      error = null;
      result = null;
    });
    try {
      final r = await ScanService.analyze(bytes);
      if (!mounted) return;
      setState(() {
        result = r;
        scanning = false;
      });
    } on ScanException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        scanning = false;
      });
    }
  }

  void _reset() => setState(() {
    img = null;
    result = null;
    error = null;
    scanning = false;
  });

  Widget _preview() {
    if (camLoading) {
      return const Center(
        child: CircularProgressIndicator(color: C.lime, strokeWidth: 3),
      );
    }
    if (cam != null) return Center(child: CameraPreview(cam!));
    return Center(
      child: Transform.translate(
        offset: Offset(0, -6 + c.value * 12),
        child: const WasteIcon(
          'plastik',
          size: 150,
          color: C.lime,
          detail: C.forest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Backdrop(
      dark: true,
      child: SafeArea(
        child: Column(
          children: [
            const TopBar('Scan Sampah', dark: true),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: c,
                  builder: (_, _) => Container(
                    width: 290,
                    height: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2B20),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: img != null
                                ? Image.memory(img!, fit: BoxFit.cover)
                                : _preview(),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: CustomPaint(painter: BracketPainter()),
                          ),
                        ),
                        if (scanning)
                          Positioned(
                            top: 30 + c.value * 250,
                            left: 26,
                            right: 26,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: C.lime,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: C.lime.withValues(alpha: .8),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          right: -12,
                          top: -36,
                          child: Mascot(size: 88, mood: _mood),
                        ),
                        Positioned(
                          left: -20,
                          bottom: -24,
                          child: Mascot(
                            kind: Kind.bino,
                            size: 98,
                            mood: scanning
                                ? Mood.wow
                                : (_mood == Mood.happy ? Mood.wink : _mood),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: result != null
                  ? _result(result!)
                  : (error != null ? _error() : _hint()),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _hint() {
    final broken = camError != null;
    return Padding(
      key: const ValueKey('hint'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        children: [
          Text(
            broken
                ? 'Kamera tidak tersedia'
                : (scanning
                      ? 'Menganalisis sampah...'
                      : 'Arahkan kamera ke sampah'),
            textAlign: TextAlign.center,
            style: disp(24, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            broken
                ? camError!
                : (scanning
                      ? 'AI sedang mengenali jenis dan berat sampah.'
                      : 'Pastikan objek terlihat jelas dan terang.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          PButton(
            broken ? 'Coba Lagi' : (scanning ? 'Memindai...' : 'Pindai'),
            style: PStyle.lime,
            icon: broken
                ? Icons.refresh_rounded
                : Icons.center_focus_strong_rounded,
            onTap: broken
                ? _retryCamera
                : ((scanning || cam == null) ? null : _shoot),
          ),
        ],
      ),
    );
  }

  Widget _error() => Container(
    key: const ValueKey('error'),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE3E1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.error_outline_rounded, color: C.danger),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text('Pemindaian gagal', style: disp(20))),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              error!,
              style: const TextStyle(
                color: C.muted,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PButton(
                  'Ulangi',
                  style: PStyle.ghost,
                  onTap: img != null ? () => _analyze(img!) : _reset,
                ),
              ),
              if (!ScanService.hasKey) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PButton(
                    'Pakai Hasil Contoh',
                    onTap: () => setState(() {
                      result = ScanService.demo();
                      error = null;
                    }),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );

  Widget _result(ScanResult r) {
    final pts = (r.kg * typeOf(r.jenis).ptsPerKg).round();
    return Container(
      key: const ValueKey('result'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SoftCard(
        padding: const EdgeInsets.all(20),
        child: r.detected
            ? Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: C.mint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: WasteIcon(
                            r.jenis,
                            size: 30,
                            color: C.pine,
                            detail: C.mint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(r.nama, style: disp(20))),
                      Pill(r.demo ? 'Contoh' : 'Terdeteksi'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _row('Kondisi', r.kondisi),
                  _row('Estimasi berat', '${fmt(r.kg, dec: 1)} kg'),
                  _row('Estimasi poin', '+$pts'),
                  if (r.catatan.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          r.catatan,
                          style: const TextStyle(
                            color: C.muted,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PButton(
                          'Pindai Ulang',
                          style: PStyle.ghost,
                          onTap: _reset,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PButton(
                          'Lanjut Pickup',
                          icon: Icons.arrow_forward_rounded,
                          onTap: () {
                            final w = ((r.kg * 2).round() / 2)
                                .clamp(.5, 50.0)
                                .toDouble();
                            app.resetDraft(types: {r.jenis}, kg: w);
                            Navigator.pushReplacement(
                              context,
                              fade(const PickupFlow()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Text('Sampah belum terdeteksi', style: disp(21)),
                  const SizedBox(height: 8),
                  Text(
                    r.catatan.isEmpty
                        ? 'Coba foto lebih dekat dengan cahaya yang cukup.'
                        : r.catatan,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: C.muted, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  PButton('Coba Lagi', onTap: _reset),
                ],
              ),
      ),
    );
  }

  Widget _row(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Text(
          a,
          style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(b, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

// ======================================================== Request pickup (3 langkah)
class PickupFlow extends StatefulWidget {
  const PickupFlow({super.key});
  @override
  State<PickupFlow> createState() => _PickupFlowState();
}

class _PickupFlowState extends State<PickupFlow> {
  final pc = PageController();
  int step = 0;

  void go(int s) {
    setState(() => step = s);
    pc.animateToPage(
      s,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Backdrop(
      child: SafeArea(
        child: Column(
          children: [
            const TopBar('Request Pickup'),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 14),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: i <= step ? C.leaf : C.line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: pc,
                physics: const NeverScrollableScrollPhysics(),
                children: const [_StepType(), _StepWhere(), _StepConfirm()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  if (step > 0) ...[
                    Expanded(
                      child: PButton(
                        'Kembali',
                        style: PStyle.ghost,
                        onTap: () => go(step - 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: PButton(
                      step == 2 ? 'Konfirmasi Pickup' : 'Lanjut',
                      icon: Icons.arrow_forward_rounded,
                      onTap: () {
                        if (step == 0 && app.selected.isEmpty) {
                          toast(context, 'Pilih minimal satu jenis sampah');
                          return;
                        }
                        if (step < 2) {
                          go(step + 1);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            fade(const TrackingScreen()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StepType extends StatelessWidget {
  const _StepType();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      children: [
        const SpeechRow(text: 'Pilih sampah yang mau dijemput, ya!'),
        const Headline('Pilih jenis sampah', hi: 'sampah', size: 29),
        const SizedBox(height: 4),
        const Text('Boleh lebih dari satu.', style: TextStyle(color: C.muted)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .92,
          children: [
            for (final t in wasteTypes)
              GestureDetector(
                onTap: () {
                  app.selected.contains(t.id)
                      ? app.selected.remove(t.id)
                      : app.selected.add(t.id);
                  app.touch();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  decoration: BoxDecoration(
                    color: app.selected.contains(t.id)
                        ? C.forest
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: app.selected.contains(t.id) ? C.forest : C.line,
                      width: 1.3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WasteIcon(
                        t.id,
                        size: 40,
                        color: app.selected.contains(t.id) ? C.lime : C.leaf,
                        detail: app.selected.contains(t.id)
                            ? C.forest
                            : Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: app.selected.contains(t.id)
                              ? Colors.white
                              : C.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Perkiraan berat',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              CircleBtn(Icons.remove_rounded, () {
                if (app.weight > .5) {
                  app.weight -= .5;
                  app.touch();
                }
              }),
              SizedBox(
                width: 76,
                child: Center(
                  child: Text(
                    '${fmt(app.weight, dec: 1)} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              CircleBtn(Icons.add_rounded, () {
                app.weight += .5;
                app.touch();
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppField(
          'Catatan untuk kurir',
          icon: Icons.edit_note_rounded,
          hint: 'Contoh: titip di pos satpam',
          maxLines: 3,
          initial: app.notes,
          onChanged: (v) {
            app.notes = v;
            app.touch();
          },
        ),
      ],
    ),
  );
}

class _StepWhere extends StatefulWidget {
  const _StepWhere();
  @override
  State<_StepWhere> createState() => _StepWhereState();
}

class _StepWhereState extends State<_StepWhere> {
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
    children: [
      const SpeechRow(
        kind: Kind.bino,
        mood: Mood.wink,
        text: 'Kasih tahu lokasi dan jam yang pas, ya.',
      ),
      const Headline('Lokasi dan jadwal', hi: 'jadwal', size: 29),
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox(
          height: 140,
          child: CustomPaint(
            painter: MapPainter(courier: false),
            size: Size.infinite,
          ),
        ),
      ),
      const SizedBox(height: 16),
      AppField(
        'Alamat penjemputan',
        icon: Icons.place_rounded,
        initial: app.address,
        onChanged: (v) {
          app.address = v;
          app.touch();
        },
      ),
      const SizedBox(height: 20),
      const Text(
        'Tanggal',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: C.pine,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final d in ['Hari ini', 'Besok', 'Lusa'])
            ChoiceTag(d, app.date == d, () {
              setState(() => app.date = d);
              app.touch();
            }),
        ],
      ),
      const SizedBox(height: 20),
      const Text(
        'Jam jemput',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: C.pine,
          fontSize: 13,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final s in [
            '09.00 - 11.00',
            '13.00 - 15.00',
            '15.00 - 17.00',
            '17.00 - 19.00',
          ])
            ChoiceTag(s, app.slot == s, () {
              setState(() => app.slot = s);
              app.touch();
            }),
        ],
      ),
    ],
  );
}

class _StepConfirm extends StatelessWidget {
  const _StepConfirm();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      children: [
        const SpeechRow(
          mood: Mood.wow,
          text: 'Cek lagi sebelum aku panggil kurir!',
        ),
        const Headline('Konfirmasi pickup', hi: 'pickup', size: 29),
        const SizedBox(height: 4),
        const Text(
          'Periksa kembali sebelum kurir dipanggil.',
          style: TextStyle(color: C.muted),
        ),
        const SizedBox(height: 16),
        SoftCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _line(
                'Jenis',
                app.selected.map((e) => typeOf(e).label).join(', '),
              ),
              _line('Berat', '${fmt(app.weight, dec: 1)} kg'),
              _line('Alamat', app.address),
              _line('Jadwal', '${app.date}, ${app.slot}'),
              if (app.notes.trim().isNotEmpty)
                _line('Catatan', app.notes.trim()),
              const Divider(height: 28, color: C.line),
              Row(
                children: [
                  const Text(
                    'Estimasi poin',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '+${fmt(app.estPoints)}',
                    style: const TextStyle(
                      color: C.leaf,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _line(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            a,
            style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            b,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

// ======================================================== Tracking
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController move = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..forward();
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    move.dispose();
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([move, pulse]),
            builder: (_, _) => CustomPaint(
              painter: MapPainter(
                t: Curves.easeInOut.transform(move.value) * .92,
                pulse: pulse.value,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(child: const TopBar('Tracking Pickup')),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            decoration: BoxDecoration(
              color: C.sage,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: C.forest.withValues(alpha: .18),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: C.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: move,
                  builder: (_, _) => Row(
                    children: [
                      Expanded(
                        child: Text('Kurir menuju lokasimu', style: disp(22)),
                      ),
                      Pill(
                        '${((1 - move.value) * 9).ceil() + 1} menit',
                        bg: C.lime,
                        fg: C.forest,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 66,
                        height: 52,
                        decoration: BoxDecoration(
                          color: C.mint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: KuriArt(width: 54)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budi Santoso',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Mitra kurir  |  D 4821 EC',
                              style: TextStyle(color: C.muted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      CircleBtn(
                        Icons.call_rounded,
                        () =>
                            toast(context, 'Fitur ini belum tersedia di demo'),
                      ),
                      const SizedBox(width: 8),
                      CircleBtn(
                        Icons.chat_bubble_rounded,
                        () =>
                            toast(context, 'Fitur ini belum tersedia di demo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _step('Pickup dikonfirmasi', true),
                _step('Kurir dalam perjalanan', true),
                _step('Sampah dijemput', false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PButton(
                        'Batalkan',
                        style: PStyle.danger,
                        onTap: () {
                          app.cancelPickup();
                          Navigator.pushReplacement(
                            context,
                            fade(const ResultScreen(ok: false)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PButton(
                        'Sampah Diterima',
                        icon: Icons.check_rounded,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          fade(const ResultScreen(ok: true)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _step(String t, bool done) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? C.leaf : Colors.white,
            border: Border.all(color: done ? C.leaf : C.line, width: 2),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          t,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: done ? C.ink : C.muted,
          ),
        ),
      ],
    ),
  );
}

// ======================================================== Hasil (berhasil / dibatalkan)
class ResultScreen extends StatefulWidget {
  final bool ok;
  const ResultScreen({super.key, required this.ok});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  late final int pts = app.estPoints;
  late final double kg = app.weight;

  @override
  void initState() {
    super.initState();
    if (widget.ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) => app.completePickup());
    }
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void _home(int tabIndex) {
    tab.value = tabIndex;
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Backdrop(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                width: 250,
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.ok) ...const [
                      Positioned(
                        left: 14,
                        top: 22,
                        child: Sparkle(size: 26, color: C.sun),
                      ),
                      Positioned(
                        right: 14,
                        top: 8,
                        child: Sparkle(size: 34, color: C.leaf),
                      ),
                      Positioned(
                        right: 34,
                        bottom: 44,
                        child: Sparkle(size: 18, color: C.lime),
                      ),
                      Positioned(left: 28, bottom: 52, child: Coin(size: 32)),
                    ],
                    Mascot(mood: widget.ok ? Mood.cheer : Mood.sad, size: 196),
                    Positioned(
                      right: 34,
                      bottom: 4,
                      child: AnimatedBuilder(
                        animation: c,
                        builder: (_, _) => CustomPaint(
                          size: const Size(66, 66),
                          painter: MarkPainter(
                            c.value,
                            widget.ok,
                            widget.ok ? C.leaf : C.danger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Headline(
                widget.ok ? 'Pickup Berhasil' : 'Pickup Dibatalkan',
                hi: widget.ok ? 'Berhasil' : 'Dibatalkan',
                size: 36,
                align: TextAlign.center,
                accent: widget.ok ? C.leaf : C.danger,
              ),
              const SizedBox(height: 8),
              Text(
                widget.ok
                    ? 'Poin sudah masuk ke Eco-Wallet kamu.'
                    : 'Kamu bisa membuat permintaan baru kapan saja.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: C.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.ok) ...[
                const SizedBox(height: 24),
                SoftCard(
                  child: Column(
                    children: [
                      _r('Poin diterima', '+${fmt(pts)}', C.leaf),
                      _r('Berat', '${fmt(kg, dec: 1)} kg', C.ink),
                      _r(
                        'ID transaksi',
                        'ECO-2026-${app.history.length.toString().padLeft(4, '0')}',
                        C.ink,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (widget.ok) ...[
                PButton(
                  'Lihat Eco-Wallet',
                  icon: Icons.account_balance_wallet_rounded,
                  onTap: () => _home(3),
                ),
                const SizedBox(height: 12),
              ],
              PButton(
                'Kembali ke Beranda',
                style: widget.ok ? PStyle.ghost : PStyle.filled,
                onTap: () => _home(0),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _r(String a, String b, Color col) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Text(
          a,
          style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          b,
          style: TextStyle(fontWeight: FontWeight.w800, color: col),
        ),
      ],
    ),
  );
}

import 'package:material_ui/material_ui.dart';

import '../art.dart';
import '../characters.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'entry.dart';
import 'pickup.dart';

// ======================================================== Shell + bottom nav
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: tab,
    builder: (_, i, _) => Scaffold(
      extendBody: true,
      body: Backdrop(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: i,
            children: const [
              DashboardTab(),
              ImpactTab(),
              HistoryTab(),
              WalletTab(),
              ProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _NavBar(index: i),
    ),
  );
}

class _NavBar extends StatelessWidget {
  final int index;
  const _NavBar({required this.index});
  static const items = [
    (Icons.home_rounded, 'Beranda'),
    (Icons.insights_rounded, 'Dampak'),
    (Icons.receipt_long_rounded, 'Riwayat'),
    (Icons.account_balance_wallet_rounded, 'Dompet'),
    (Icons.person_rounded, 'Profil'),
  ];
  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.only(bottom: 12),
    child: Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: C.forest,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: C.forest.withValues(alpha: .35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tab.value = i,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: i == index ? 16 : 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: i == index ? C.lime : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].$1,
                      size: 22,
                      color: i == index ? C.forest : Colors.white60,
                    ),
                    if (i == index) ...[
                      const SizedBox(width: 6),
                      Text(
                        items[i].$2,
                        style: const TextStyle(
                          color: C.forest,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// ======================================================== Tile riwayat (dipakai di beberapa tab)
class PickupTile extends StatelessWidget {
  final PickupRecord r;
  const PickupTile(this.r, {super.key});
  @override
  Widget build(BuildContext context) {
    final ok = r.status == 'Selesai';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
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
                  r.primary,
                  size: 30,
                  color: C.pine,
                  detail: C.mint,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.date}  |  ${fmt(r.kg, dec: 1)} kg',
                    style: const TextStyle(
                      color: C.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ok ? '+${r.points}' : '0',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: ok ? C.leaf : C.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Pill(
                  r.status,
                  bg: ok ? C.mint : const Color(0xFFFBE3E1),
                  fg: ok ? C.pine : C.danger,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================== Beranda
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
      children: [
        Reveal(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${app.name}',
                      style: const TextStyle(
                        color: C.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Headline(
                      'Siap memilah\nhari ini?',
                      hi: 'hari ini?',
                      size: 36,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => tab.value = 4,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [C.leaf, C.pine]),
                  ),
                  child: Text(
                    app.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Reveal(delay: 90, child: _HeroCard(points: app.points)),
        const SizedBox(height: 16),
        Reveal(
          delay: 170,
          child: Row(
            children: [
              Expanded(
                child: _Stat(
                  Icons.recycling_rounded,
                  'Total sampah',
                  '${fmt(app.totalKg, dec: 1)} kg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  Icons.cloud_done_outlined,
                  'Emisi dihemat*',
                  '${fmt(app.co2, dec: 1)} kg',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Reveal(
          delay: 200,
          child: _Banner(
            const Color(0xFFB7E58B),
            'Tukar sampah\njadi poin',
            'Scan dan kumpulkan',
            Icons.center_focus_strong_rounded,
            () => Navigator.push(context, fade(const ScanScreen())),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: 230,
          child: _Banner(
            const Color(0xFFB7E58B),
            'Kurir datang\nke rumah',
            'Pickup on-demand',
            Icons.local_shipping_rounded,
            () {
              app.resetDraft();
              Navigator.push(context, fade(const PickupFlow()));
            },
          ),
        ),
        const SectionTitle('Menu cepat'),
        Reveal(
          delay: 260,
          child: Row(
            children: [
              _Quick(
                Icons.center_focus_strong_rounded,
                'Scan',
                C.mint,
                () => Navigator.push(context, fade(const ScanScreen())),
              ),
              _Quick(Icons.local_shipping_rounded, 'Pickup', C.mint, () {
                app.resetDraft();
                Navigator.push(context, fade(const PickupFlow()));
              }),
              _Quick(
                Icons.menu_book_rounded,
                'Edukasi',
                C.mint,
                () => _education(context),
              ),
              _Quick(
                Icons.payments_rounded,
                'Tukar',
                C.mint,
                () => tab.value = 3,
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const SectionTitle('Panduan memilah'),
            const Positioned(
              right: 4,
              top: 4,
              child: Mascot(kind: Kind.bino, size: 62),
            ),
          ],
        ),
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: wasteTypes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final t = wasteTypes[i];
              return SizedBox(
                width: 150,
                child: SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: C.mint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: WasteIcon(
                            t.id,
                            size: 30,
                            color: C.pine,
                            detail: C.mint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.label,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.tip,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: C.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SectionTitle('Aktivitas terakhir'),
        for (final r in app.history.take(2)) PickupTile(r),
        const Padding(
          padding: EdgeInsets.only(top: 6, left: 2),
          child: Text(
            '*Estimasi berdasarkan faktor emisi rata-rata.',
            style: TextStyle(color: C.muted, fontSize: 11.5),
          ),
        ),
      ],
    ),
  );

  void _education(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        decoration: const BoxDecoration(
          color: C.sage,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
            const Text(
              'Edukasi memilah sampah',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            for (final t in wasteTypes.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      WasteIcon(
                        t.id,
                        size: 34,
                        color: C.leaf,
                        detail: Colors.white,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              t.tip,
                              style: const TextStyle(
                                color: C.muted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int points;
  const _HeroCard({required this.points});
  @override
  Widget build(BuildContext context) => Container(
    height: 218,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [C.forest, C.pine],
      ),
      boxShadow: [
        BoxShadow(
          color: C.forest.withValues(alpha: .3),
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: BlobPainter(true))),
          const Positioned(
            right: 4,
            bottom: 2,
            child: Mascot(mood: Mood.cheer, size: 132),
          ),
          const Positioned(
            right: 118,
            top: 20,
            child: Sparkle(size: 20, color: C.lime),
          ),
          const Positioned(right: 20, top: 16, child: Coin(size: 34)),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Pill(
                  'Eco-Wallet',
                  bg: Color(0x26FFFFFF),
                  fg: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  fmt(points),
                  style: disp(54, color: Colors.white, height: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  'poin  |  setara Rp${fmt(points * 10)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                PButton(
                  'Pindai Sampah',
                  style: PStyle.lime,
                  compact: true,
                  icon: Icons.arrow_forward_rounded,
                  onTap: () =>
                      Navigator.push(context, fade(const ScanScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Banner extends StatelessWidget {
  final Color color;
  final String title, sub;
  final IconData icon;
  final VoidCallback onTap;
  const _Banner(this.color, this.title, this.sub, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(26),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: disp(21, height: 1.05)),
                  const SizedBox(height: 6),
                  Text(
                    sub,
                    style: TextStyle(
                      color: C.forest.withValues(alpha: .7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: C.forest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: C.lime, size: 22),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Stat(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: C.mint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: C.pine, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: C.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final VoidCallback onTap;
  const _Quick(this.icon, this.label, this.bg, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: C.forest.withValues(alpha: .06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: C.pine, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

// ======================================================== Dampak
class ImpactTab extends StatelessWidget {
  const ImpactTab({super.key});
  static const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final maxW = app.weekly.reduce((a, b) => a > b ? a : b);
      final lvl = app.totalKg < 10
          ? ('Eco Starter', 10.0)
          : app.totalKg < 30
          ? ('Eco Hero', 30.0)
          : ('Eco Legend', 60.0);
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
        children: [
          const Headline('Dampak kamu', hi: 'kamu', size: 36),
          const SizedBox(height: 4),
          const Text(
            'Kontribusi nyata dari setiap pilahan.',
            style: TextStyle(color: C.muted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [C.forest, C.pine],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: app.totalKg / app.monthlyGoal),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => CustomPaint(
                      painter: RingPainter(v, bg: Colors.white12, fg: C.lime),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              fmt(app.totalKg, dec: 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'kg',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target bulan ini',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${fmt(app.monthlyGoal)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Emisi dihemat*',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${fmt(app.co2, dec: 1)} kg CO2e',
                        style: const TextStyle(
                          color: C.lime,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('Minggu ini'),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
            child: SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            fmt(app.weekly[i], dec: 1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: C.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: app.weekly[i] / maxW),
                            duration: Duration(milliseconds: 700 + i * 90),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => Container(
                              height: 100 * v + 6,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: i == 6
                                      ? const [C.lime, C.leaf]
                                      : [C.mint, C.leaf.withValues(alpha: .55)],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            days[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: i == 6 ? C.forest : C.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SectionTitle('Komposisi sampah'),
          SoftCard(
            child: Column(
              children: [
                for (final e in app.breakdown.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              e.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${fmt(e.value, dec: 1)} kg',
                              style: const TextStyle(
                                color: C.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: e.value / app.totalKg),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 9,
                              backgroundColor: C.mint.withValues(alpha: .6),
                              color: C.leaf,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Badge'),
          SoftCard(
            color: C.forest,
            child: Row(
              children: [
                const Mascot(mood: Mood.cheer, size: 78),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lvl.$1, style: disp(23, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        '${fmt(lvl.$2 - app.totalKg, dec: 1)} kg lagi ke level berikutnya',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14, left: 2),
            child: Text(
              '*Estimasi berdasarkan faktor emisi rata-rata.',
              style: TextStyle(color: C.muted, fontSize: 11.5),
            ),
          ),
        ],
      );
    },
  );
}

// ======================================================== Riwayat
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String filter = 'Semua';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) {
      final list = app.history
          .where((r) => filter == 'Semua' || r.status == filter)
          .toList();
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
        children: [
          const Headline('Riwayat pickup', hi: 'pickup', size: 36),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in ['Semua', 'Selesai', 'Dibatalkan']) ...[
                  ChoiceTag(f, filter == f, () => setState(() => filter = f)),
                  const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                child: Column(
                  children: [
                    Mascot(kind: Kind.bino, mood: Mood.sad, size: 140),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada pickup',
                      style: TextStyle(
                        color: C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final r in list) PickupTile(r),
        ],
      );
    },
  );
}

// ======================================================== Dompet
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
      children: [
        const Headline('Eco-Wallet', hi: 'Wallet', size: 36),
        const SizedBox(height: 18),
        Container(
          height: 196,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [C.forest, C.pine],
            ),
            boxShadow: [
              BoxShadow(
                color: C.forest.withValues(alpha: .3),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: BlobPainter(true))),
                const Positioned(right: 28, top: 66, child: Coin(size: 56)),
                const Positioned(
                  right: 92,
                  top: 58,
                  child: Sparkle(size: 18, color: C.lime),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Total poin',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Logo(
                            size: 30,
                            color: Colors.white,
                            accent: C.lime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fmt(app.points),
                        style: disp(58, color: Colors.white, height: 1),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'Rp${fmt(app.rupiah)}',
                            style: const TextStyle(
                              color: C.lime,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '100 poin = Rp1.000',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PButton(
          'Cairkan ke e-wallet',
          icon: Icons.north_east_rounded,
          onTap: () => _withdraw(context),
        ),
        const SectionTitle('Riwayat transaksi'),
        for (final t in app.tx)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: t.amount > 0 ? C.mint : const Color(0xFFFBE3E1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      t.amount > 0
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      color: t.amount > 0 ? C.pine : C.danger,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t.date,
                          style: const TextStyle(color: C.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${t.amount > 0 ? '+' : '-'}${fmt(t.amount.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: t.amount > 0 ? C.leaf : C.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  void _withdraw(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _WithdrawSheet(),
  );
}

class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet();
  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  int p = 0, amt = 500;
  static const providers = [
    ('GoPay', Color(0xFF00AED6)),
    ('OVO', Color(0xFF4C2A86)),
    ('DANA', Color(0xFF118EEA)),
  ];
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
    decoration: const BoxDecoration(
      color: C.sage,
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
        const Text(
          'Cairkan poin',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < providers.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => p = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: p == i ? C.leaf : C.line,
                        width: p == i ? 2 : 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: providers[i].$2,
                          child: Text(
                            providers[i].$1[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          providers[i].$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Jumlah poin',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: C.pine,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            for (final a in [500, 1000, 2000])
              Opacity(
                opacity: app.points >= a ? 1 : .35,
                child: ChoiceTag('${fmt(a)} poin', amt == a, () {
                  if (app.points >= a) setState(() => amt = a);
                }),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Diterima: Rp${fmt(amt * 10)}',
          style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        PButton(
          'Cairkan Sekarang',
          onTap: () {
            if (app.points < amt) {
              toast(context, 'Poin belum cukup');
              return;
            }
            // TODO: panggil API pencairan
            app.withdraw(providers[p].$1, amt);
            Navigator.pop(context);
            toast(
              context,
              'Permintaan pencairan ke ${providers[p].$1} dikirim',
            );
          },
        ),
      ],
    ),
  );
}

// ======================================================== Profil
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
      children: [
        const Headline('Profil kamu', hi: 'kamu', size: 36),
        const SizedBox(height: 20),
        SoftCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.mint,
                ),
                child: const Center(child: Mascot(mood: Mood.wink, size: 104)),
              ),
              const SizedBox(height: 14),
              Text(app.name, style: disp(27)),
              const SizedBox(height: 2),
              Text(
                app.email,
                style: const TextStyle(
                  color: C.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _mini(
                    '${app.history.where((r) => r.status == 'Selesai').length}',
                    'Pickup',
                  ),
                  _mini(fmt(app.totalKg, dec: 1), 'Kg'),
                  _mini(fmt(app.points), 'Poin'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final m in const [
          (Icons.person_outline_rounded, 'Data diri'),
          (Icons.place_outlined, 'Alamat tersimpan'),
          (Icons.notifications_none_rounded, 'Notifikasi'),
          (Icons.help_outline_rounded, 'Bantuan'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () => toast(context, 'Fitur ini belum tersedia di demo'),
              child: Row(
                children: [
                  Icon(m.$1, color: C.leaf),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      m.$2,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: C.muted),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        PButton(
          'Keluar',
          style: PStyle.danger,
          icon: Icons.logout_rounded,
          onTap: () async {
            await app.logout();
            tab.value = 0;
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              fade(const AuthScreen()),
              (r) => false,
            );
          },
        ),
      ],
    ),
  );

  Widget _mini(String v, String l) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(
          l,
          style: const TextStyle(
            color: C.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'game_ui.dart';
import 'onboarding_screen.dart';
import 'strings.dart';

/// Cold open: the last signal of the Opportunity rover. Same text for every age (age is not known yet).
const _starts = [0.0, 3.5, 8.0, 14.0, 21.0, 27.0]; // seconds at which each story line begins
const _total = 32.0;

class StoryIntroScreen extends StatefulWidget {
  const StoryIntroScreen({super.key});
  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 32));
  int _line = 0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_tick);
    _c.forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  void _tick() {
    final sec = _c.value * _total;
    var i = 0;
    while (i + 1 < _starts.length && sec >= _starts[i + 1]) { i++; }
    if (i != _line) {
      setState(() => _line = i);
      if (i == 3) HapticFeedback.mediumImpact(); // the quote lands
    }
  }

  void _advance() {
    final sec = _c.value * _total;
    final next = _starts.where((x) => x > sec + .05);
    if (next.isNotEmpty) _c.forward(from: next.first / _total);
  }

  void _go() => Navigator.of(context).pushReplacement(gameRoute(const OnboardingScreen()));

  double _dark(double sec) => Curves.easeInOut.transform(((sec - 3) / 16).clamp(0.0, 1.0).toDouble());

  Widget _panel(AppState s) {
    final quote = _line == 3;
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: GC.bgBottom.withValues(alpha: .72), borderRadius: BorderRadius.circular(24),
        border: Border.all(color: quote ? GC.gold : Colors.white24, width: 3),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Column(key: ValueKey(_line), mainAxisSize: MainAxisSize.min, children: [
            Text(tr(s, 'story_$_line'), textAlign: TextAlign.center, style: gameText(_line == 0 ? 32 : 21, color: Colors.white, weight: 700)),
            if (quote) ...[
              const SizedBox(height: 12),
              OutlinedText(tr(s, 'story_quote'), size: 28),
              const SizedBox(height: 6),
              Text(tr(s, 'story_caption'), textAlign: TextAlign.center, style: gameText(14, color: Colors.white70, weight: 500)),
            ],
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final fin = _line == _starts.length - 1;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: fin ? null : _advance,
        child: Stack(children: [
          const GameBackground(child: SizedBox.shrink()), // purple world, revealed at the end
          AnimatedOpacity(
            duration: const Duration(milliseconds: 1500),
            opacity: fin ? 0 : 1,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final sec = _c.value * _total;
                return SizedBox.expand(child: CustomPaint(painter: _MarsPainter(sec, _dark(sec))));
              },
            ),
          ),
          if (!fin) ...[
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) {
                      final sec = _c.value * _total;
                      final level = (1 - _dark(sec)).clamp(.04, 1.0).toDouble();
                      return _BatteryMeter(level: level, blink: level < .3 && (sec * 2).floor().isEven, label: tr(s, 'battery'));
                    },
                  ),
                ),
              ),
            ),
            SafeArea(child: Align(alignment: const Alignment(0, -.2), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _panel(s)))),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: ChunkyButton(label: tr(s, 'skip'), small: true, wide: false, color: GC.violet, dark: GC.violetDark, onTap: _go),
                ),
              ),
            ),
          ],
          if (fin)
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SpeechBubble(tr(s, 'story_5'), size: 20),
                    const Roby(size: 130),
                    const SizedBox(height: 24),
                    SizedBox(width: 280, child: ChunkyButton(label: tr(s, 'story_go'), onTap: _go)),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _BatteryMeter extends StatelessWidget {
  const _BatteryMeter({required this.level, required this.blink, required this.label});
  final double level;
  final bool blink;
  final String label;
  @override
  Widget build(BuildContext context) {
    final col = level > .5 ? GC.teal : (level > .3 ? GC.orange : const Color(0xFFFF4D4D));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: gameText(15, color: Colors.white, weight: 700, shadows: const [Shadow(color: Colors.black54, blurRadius: 4)])),
      const SizedBox(width: 8),
      Container(
        width: 58, height: 28, padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(8)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: level, heightFactor: 1,
            child: DecoratedBox(decoration: BoxDecoration(color: blink ? Colors.transparent : col, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ),
      Container(width: 4, height: 12, decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.horizontal(right: Radius.circular(3)))),
    ]);
  }
}

/// Mars at dusk that slowly goes dark, with a little solar-powered rover in the foreground.
class _MarsPainter extends CustomPainter {
  _MarsPainter(this.sec, this.dark);
  final double sec, dark;
  Color d(Color c) => Color.lerp(c, const Color(0xFF07040F), dark)!;

  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [d(const Color(0xFFE9A36A)), d(const Color(0xFFC96B45))], stops: const [0, .75]).createShader(r));
    final sunA = (1 - dark * 1.5).clamp(0.0, 1.0).toDouble(); // the Sun fades behind the dust
    if (sunA > 0) {
      final o = Offset(s.width * .78, s.height * .58);
      c.drawCircle(o, 40, Paint()..color = const Color(0xFFFFF1C2).withValues(alpha: .5 * sunA)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
      c.drawCircle(o, 17, Paint()..color = const Color(0xFFFFF6D6).withValues(alpha: sunA));
    }
    final y0 = s.height * .70;
    final ground = Path()..moveTo(0, s.height)..lineTo(0, y0);
    for (double x = 0; x <= s.width + 12; x += 12) { ground.lineTo(x, y0 + sin(x / s.width * 6) * 6); }
    ground..lineTo(s.width, s.height)..close();
    final gr = Rect.fromLTWH(0, y0 - 10, s.width, s.height - y0 + 10);
    c.drawPath(ground, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [d(const Color(0xFFA2502F)), d(const Color(0xFF5E2A1B))]).createShader(gr));
    final rock = Paint()..color = d(const Color(0xFF6E311E));
    for (final p in const [(.12, .88, 30.0, 11.0), (.86, .84, 24.0, 9.0), (.3, .94, 40.0, 13.0), (.72, .93, 28.0, 10.0)]) {
      c.drawOval(Rect.fromCenter(center: Offset(s.width * p.$1, s.height * p.$2), width: p.$3, height: p.$4), rock);
    }
    _rover(c, s);
    final n = (14 + 40 * dark).round(); // dust streaks get thicker as the storm grows
    for (var i = 0; i < n; i++) {
      final sp = .3 + (i % 5) * .12;
      final x = ((((i * 37) % 100) / 100) + sec * .03 * sp * (1 + dark * 2)) % 1.0 * s.width;
      final y = (((i * 53) % 100) / 100) * s.height * .85;
      final len = 40.0 + (i % 7) * 14;
      c.drawLine(Offset(x, y), Offset(x - len, y + len * .08),
          Paint()..color = const Color(0xFFE2B58E).withValues(alpha: .10 + .22 * dark)..strokeWidth = 2.0 + (i % 3) * 1.5..strokeCap = StrokeCap.round);
    }
    c.drawRect(r, Paint()..color = const Color(0xFF3A1A10).withValues(alpha: .25 * dark));
  }

  void _rover(Canvas c, Size s) {
    final w = s.width * .55;
    c.save();
    c.translate(s.width * .5 - w / 2, s.height * .745);
    c.scale(w / 100);
    c.saveLayer(const Rect.fromLTWH(-10, -10, 120, 80), Paint()..colorFilter = ColorFilter.mode(const Color(0xFF07040F).withValues(alpha: dark * .65), BlendMode.srcATop));
    final ol = Paint()..color = const Color(0xFF2A1208)..style = PaintingStyle.stroke..strokeWidth = 2;
    Paint f(int v) => Paint()..color = Color(v);
    for (final x in [14.0, 50.0, 86.0]) {
      c.drawCircle(Offset(x, 50), 9, f(0xFF3A3A44));
      c.drawCircle(Offset(x, 50), 9, ol);
      c.drawCircle(Offset(x, 50), 3.5, f(0xFF9A9AA8));
    }
    final arm = Paint()..color = const Color(0xFF8A8A94)..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (final a in [(14.0, 32.0), (50.0, 32.0), (50.0, 68.0), (86.0, 68.0)]) { c.drawLine(Offset(a.$1, 50), Offset(a.$2, 36), arm); }
    final body = RRect.fromLTRBR(20, 28, 80, 42, const Radius.circular(4));
    c.drawRRect(body, f(0xFFE8E0CC));
    c.drawRRect(body, ol);
    final panel = Path()..moveTo(8, 27)..lineTo(92, 27)..lineTo(98, 20)..lineTo(14, 20)..close(); // solar deck
    c.drawPath(panel, f(0xFF1F3A7A));
    c.drawPath(panel, ol);
    final grid = Paint()..color = const Color(0x66A9C1FF)..strokeWidth = 1;
    for (var i = 1; i < 5; i++) { c.drawLine(Offset(8 + i * 16.8, 27), Offset(14 + i * 16.8, 20), grid); }
    c.drawLine(const Offset(28, 20), const Offset(28, 4), Paint()..color = const Color(0xFFBFB8A8)..strokeWidth = 2.4..strokeCap = StrokeCap.round); // mast
    final head = RRect.fromLTRBR(21, 0, 37, 8, const Radius.circular(2));
    c.drawRRect(head, f(0xFF55555F));
    c.drawRRect(head, ol);
    c.drawCircle(const Offset(26, 4), 1.8, f(0xFF9FE9FF));
    c.drawCircle(const Offset(32, 4), 1.8, f(0xFF9FE9FF));
    c.restore(); // end of dimming layer
    if (dark > .6 && (sec * 2).floor().isEven) c.drawCircle(const Offset(70, 35), 2.4, f(0xFFFF3B3B)); // low-battery light
    c.restore();
  }

  @override
  bool shouldRepaint(_MarsPainter old) => true;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Game palette (cosmic purple world + candy-bright buttons).
class GC {
  static const bgTop = Color(0xFF2B0F5C),
      bgMid = Color(0xFF4A1A8C),
      bgBottom = Color(0xFF1B0B45);
  static const orange = Color(0xFFFF8A1F), orangeDark = Color(0xFFC25A00);
  static const pink = Color(0xFFFF4FA3), pinkDark = Color(0xFFB02470);
  static const violet = Color(0xFF8A5BFF), violetDark = Color(0xFF5430BE);
  static const teal = Color(0xFF22D3C5), tealDark = Color(0xFF0B8A82);
  static const gold = Color(0xFFFFD43B), outline = Color(0xFF260A52);
  static const grey = Color(0xFF8E86A8), greyDark = Color(0xFF5F5878);
}

TextStyle gameText(double size,
        {Color? color, int weight = 800, List<Shadow>? shadows}) =>
    TextStyle(
      fontFamily: 'Baloo',
      fontSize: size,
      color: color,
      height: 1.1,
      shadows: shadows,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
    );

ThemeData gameTheme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Baloo',
      colorScheme: ColorScheme.fromSeed(
          seedColor: GC.violet, brightness: Brightness.dark),
      scaffoldBackgroundColor: GC.bgBottom,
    );

Route<T> gameRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
            scale: Tween<double>(begin: .94, end: 1).animate(
                CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child),
      ),
    );

// ───────────────────────── Chunky 3D button ─────────────────────────
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.color = GC.orange,
    this.dark = GC.orangeDark,
    this.wide = true,
    this.small = false,
  });
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap; // null = disabled
  final Color color, dark;
  final bool wide, small;
  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    final color = on ? widget.color : GC.grey,
        dark = on ? widget.dark : GC.greyDark;
    final lift = (_down && on) ? 0.0 : 6.0;
    final light = Color.lerp(color, Colors.white, .3)!;
    return GestureDetector(
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapUp: on
          ? (_) {
              setState(() => _down = false);
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(0, 6 - lift, 0),
        width: widget.wide ? double.infinity : null,
        alignment: widget.wide ? Alignment.center : null,
        padding: EdgeInsets.symmetric(
            horizontal: widget.small ? 18 : 28,
            vertical: widget.small ? 8 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [light, color],
              stops: const [0, .6]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: GC.outline, width: 3),
          boxShadow: [
            BoxShadow(color: dark, offset: Offset(0, lift)),
            BoxShadow(
                color: const Color(0x55000000),
                blurRadius: 14,
                offset: Offset(0, lift + 6)),
          ],
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null)
                Icon(widget.icon,
                    color: Colors.white, size: widget.small ? 22 : 28),
              if (widget.icon != null && widget.label != null)
                const SizedBox(width: 8),
              if (widget.label != null)
                Flexible(
                    child: Text(widget.label!,
                        textAlign: TextAlign.center,
                        style: gameText(widget.small ? 17 : 22,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: dark, offset: const Offset(0, 2.5))
                            ]))),
            ]),
      ),
    );
  }
}

// ───────────────────────── Outlined logo-style text ─────────────────────────
class OutlinedText extends StatelessWidget {
  const OutlinedText(this.text,
      {super.key, this.size = 42, this.fill = GC.gold});
  final String text;
  final double size;
  final Color fill;
  @override
  Widget build(BuildContext context) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size / 5
      ..strokeJoin = StrokeJoin.round
      ..color = GC.outline;
    return Stack(alignment: Alignment.center, children: [
      Text(text,
          textAlign: TextAlign.center,
          style: gameText(size).copyWith(foreground: stroke)),
      Text(text,
          textAlign: TextAlign.center,
          style: gameText(size, color: fill, shadows: [
            Shadow(color: const Color(0xFFC98A00), offset: Offset(0, size / 14))
          ])),
    ]);
  }
}

// ───────────────────────── Chunky text field ─────────────────────────
class GameTextField extends StatelessWidget {
  const GameTextField(
      {super.key,
      required this.controller,
      required this.hint,
      this.onSubmitted});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: GC.outline, width: 4),
          boxShadow: const [
            BoxShadow(color: GC.violetDark, offset: Offset(0, 6))
          ],
        ),
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 20,
          onSubmitted: onSubmitted,
          cursorColor: GC.orange,
          style: gameText(28, color: GC.outline, weight: 700),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
            hintText: hint,
            hintStyle:
                gameText(24, color: const Color(0xFFB9AEDB), weight: 600),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
}

// ───────────────────────── Speech bubble ─────────────────────────
class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text,
      {super.key, this.size = 20, this.maxWidth = 340});
  final String text;
  final double size, maxWidth;
  @override
  Widget build(BuildContext context) {
    const edge = BorderSide(color: GC.outline, width: 4);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: GC.outline, width: 4),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), offset: Offset(0, 6))
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: a, child: c)),
          child: Text(text,
              key: ValueKey(text),
              textAlign: TextAlign.center,
              style: gameText(size, color: GC.outline, weight: 700)),
        ),
      ),
      Transform.translate(
        offset: const Offset(0, -12),
        child: Transform.rotate(
          angle: pi / 4,
          child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(right: edge, bottom: edge))),
        ),
      ),
    ]);
  }
}

// ───────────────────────── Roby the mascot ─────────────────────────
class Roby extends StatefulWidget {
  const Roby({super.key, this.size = 130});
  final double size;
  @override
  State<Roby> createState() => _RobyState();
}

class _RobyState extends State<Roby> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value;
          final blink = (t > .62 && t < .66) ? .15 : 1.0;
          return Transform.translate(
            offset: Offset(0, sin(t * 2 * pi) * 5),
            child: CustomPaint(
                size: Size.square(widget.size), painter: _RobyPainter(blink)),
          );
        },
      );
}

class _RobyPainter extends CustomPainter {
  _RobyPainter(this.blink);
  final double blink;
  @override
  void paint(Canvas c, Size sz) {
    c.scale(sz.width / 100);
    final ol = Paint()
      ..color = GC.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    RRect rr(double l, double t, double w, double h, double r) =>
        RRect.fromLTRBR(l, t, l + w, t + h, Radius.circular(r));
    Paint solid(Color col) => Paint()..color = col;
    c.drawLine(const Offset(50, 22), const Offset(50, 10), ol); // antenna
    c.drawCircle(const Offset(50, 8), 6, solid(GC.orange));
    c.drawCircle(const Offset(50, 8), 6, ol);
    for (final x in [10.0, 90.0]) {
      // ears
      c.drawCircle(Offset(x, 52), 8, solid(GC.violet));
      c.drawCircle(Offset(x, 52), 8, ol);
    }
    final body = rr(32, 78, 36, 18, 9);
    c.drawRRect(body, solid(GC.pink));
    c.drawRRect(body, ol);
    final head = rr(14, 20, 72, 62, 28);
    c.drawRRect(
        head,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xFFD9D0FF)])
              .createShader(head.outerRect));
    c.drawRRect(head, ol);
    c.drawRRect(
        rr(24, 34, 52, 34, 16), solid(const Color(0xFF1B0B45))); // visor
    const cyan = Color(0xFF3DF2E6);
    for (final x in [39.0, 61.0]) {
      // eyes (blink = vertical squash)
      c.save();
      c.translate(x, 50);
      c.scale(1, blink);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: 10, height: 13),
          solid(cyan));
      c.drawCircle(const Offset(-1.5, -2.5), 1.8, solid(Colors.white));
      c.restore();
    }
    c.drawArc(
        Rect.fromCenter(center: const Offset(50, 58), width: 12, height: 8),
        0.2,
        2.7,
        false,
        Paint()
          ..color = cyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RobyPainter old) => old.blink != blink;
}

// ───────────────────────── Animated space background ─────────────────────────
class _Star {
  _Star(this.x, this.y, this.r, this.phase);
  final double x, y, r, phase;
}

class GameBackground extends StatefulWidget {
  const GameBackground({super.key, required this.child});
  final Widget child;
  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat();
  late final List<_Star> _stars = () {
    final r = Random(7);
    return List.generate(
        70,
        (_) => _Star(r.nextDouble(), r.nextDouble(), r.nextDouble() * 1.8 + .8,
            r.nextDouble()));
  }();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (_, child) => SizedBox.expand(
            child: CustomPaint(
                painter: _BgPainter(_c.value, _stars), child: child)),
      );
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.t, this.stars);
  final double t;
  final List<_Star> stars;
  @override
  void paint(Canvas c, Size s) {
    final r = Offset.zero & s;
    c.drawRect(
        r,
        Paint()
          ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [GC.bgTop, GC.bgMid, GC.bgBottom]).createShader(r));
    for (final st in stars) {
      final a = .3 + .7 * (.5 + .5 * sin((t * 6 + st.phase) * 2 * pi));
      c.drawCircle(Offset(st.x * s.width, st.y * s.height), st.r,
          Paint()..color = Colors.white.withValues(alpha: a));
    }
    void planet(double fx, double fy, double rad, Color a, Color b, double ph,
        {bool ring = false}) {
      final o =
          Offset(s.width * fx, s.height * fy + sin((t * 2 + ph) * 2 * pi) * 7);
      if (ring)
        c.drawOval(
            Rect.fromCenter(center: o, width: rad * 3.2, height: rad * .9),
            Paint()
              ..color = Colors.white.withValues(alpha: .35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4);
      c.drawCircle(
          o,
          rad,
          Paint()
            ..shader = RadialGradient(
                    center: const Alignment(-.4, -.4), colors: [a, b])
                .createShader(Rect.fromCircle(center: o, radius: rad)));
    }

    planet(.85, .14, 32, const Color(0xFFFFB347), GC.pinkDark, 0, ring: true);
    planet(.10, .66, 22, const Color(0xFF7CF5E8), GC.tealDark, .5);
    // moon-surface ground at the bottom
    final g = Rect.fromCenter(
        center: Offset(s.width / 2, s.height * 1.02),
        width: s.width * 1.7,
        height: s.height * .26);
    c.drawOval(
        g,
        Paint()
          ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9B7BFF), GC.violetDark]).createShader(g));
    final crater = Paint()..color = const Color(0x33000000);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .22, s.height * .955),
            width: 48,
            height: 14),
        crater);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .72, s.height * .975),
            width: 34,
            height: 10),
        crater);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(s.width * .5, s.height * .945),
            width: 22,
            height: 7),
        crater);
  }

  @override
  bool shouldRepaint(_BgPainter old) => true;
}

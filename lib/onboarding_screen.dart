import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'game_ui.dart';
import 'strings.dart';
import 'welcome_screen.dart';

const int kMinAge = 4, kMaxAge = 99;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0; // 0 language, 1 name, 2 age
  late final TextEditingController _name;
  late int _age;

  @override
  void initState() {
    super.initState();
    final s = AppScope.read(context);
    _name = TextEditingController(text: s.name)..addListener(() => setState(() {}));
    _age = s.age;
  }

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  bool get _nameOk => _name.text.trim().isNotEmpty;

  void _next() {
    if (_step == 1 && !_nameOk) return;
    FocusScope.of(context).unfocus();
    setState(() => _step++);
  }

  Future<void> _finish() async {
    await AppScope.read(context).complete(_name.text.trim(), _age);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(gameRoute(const WelcomeScreen()));
  }

  Widget _langButton(AppState s, Lang l, String label, Color c, Color d) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ChunkyButton(
          label: label, color: c, dark: d,
          icon: s.lang == l ? Icons.check_circle_rounded : null,
          onTap: () { s.setLang(l); setState(() => _step = 1); },
        ),
      );

  Widget _content(AppState s) {
    String t(String k) => tr(s, k);
    switch (_step) {
      case 0:
        final order = s.lang == Lang.bn ? [Lang.bn, Lang.en] : [Lang.en, Lang.bn]; // guessed language on top
        return Column(key: const ValueKey(0), children: [
          for (final l in order)
            l == Lang.en ? _langButton(s, Lang.en, 'English', GC.orange, GC.orangeDark) : _langButton(s, Lang.bn, 'বাংলা', GC.pink, GC.pinkDark),
        ]);
      case 1:
        return Column(key: const ValueKey(1), children: [
          GameTextField(controller: _name, hint: t('name_hint'), onSubmitted: (_) => _next()),
          const SizedBox(height: 22),
          ChunkyButton(label: t('next'), icon: Icons.arrow_forward_rounded, color: GC.teal, dark: GC.tealDark, onTap: _nameOk ? _next : null),
        ]);
      default:
        return Column(key: const ValueKey(2), children: [
          _AgeWheel(state: s, age: _age, onChanged: (a) => _age = a),
          const SizedBox(height: 22),
          ChunkyButton(label: t('start'), icon: Icons.rocket_launch_rounded, onTap: _finish),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final bubble = tr(s, 'bubble_$_step', vars: {'name': _name.text.trim()});
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: LayoutBuilder(builder: (context, c) {
            final compact = c.maxHeight < 600; // e.g. keyboard is open
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _TopBar(step: _step, onBack: _step > 0 ? () => setState(() => _step--) : null),
                    if (_step == 0 && !compact) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: OutlinedText(tr(s, 'title'), size: 40)),
                    SpeechBubble(bubble, size: compact ? 17 : 20),
                    Roby(size: compact ? 84 : 130),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 300,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (w, a) => SlideTransition(
                          position: Tween(begin: const Offset(.25, 0), end: Offset.zero).animate(a),
                          child: FadeTransition(opacity: a, child: w),
                        ),
                        child: _content(s),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step, this.onBack});
  final int step;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: Row(children: [
          SizedBox(width: 56, child: onBack == null ? null : ChunkyButton(icon: Icons.arrow_back_rounded, small: true, wide: false, color: GC.violet, dark: GC.violetDark, onTap: onBack)),
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 3; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == step ? 36 : 12, height: 12,
                  decoration: BoxDecoration(color: i <= step ? GC.gold : Colors.white24, borderRadius: BorderRadius.circular(6), border: Border.all(color: GC.outline, width: 2)),
                ),
            ]),
          ),
          const SizedBox(width: 56),
        ]),
      );
}

/// Spin-the-wheel age picker (no keyboard, works for Bengali digits too).
class _AgeWheel extends StatefulWidget {
  const _AgeWheel({required this.state, required this.age, required this.onChanged});
  final AppState state;
  final int age;
  final ValueChanged<int> onChanged;
  @override
  State<_AgeWheel> createState() => _AgeWheelState();
}

class _AgeWheelState extends State<_AgeWheel> {
  late final FixedExtentScrollController _c = FixedExtentScrollController(initialItem: widget.age - kMinAge);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        decoration: BoxDecoration(
          color: GC.bgBottom.withValues(alpha: .75), borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GC.gold, width: 4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(alignment: Alignment.center, children: [
            IgnorePointer(child: Container(height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), border: const Border.symmetric(horizontal: BorderSide(color: Colors.white24, width: 2))))),
            ListWheelScrollView(
              controller: _c, itemExtent: 60, diameterRatio: 1.8, perspective: .004, useMagnifier: true, magnification: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (i) { HapticFeedback.selectionClick(); widget.onChanged(kMinAge + i); },
              children: [for (var a = kMinAge; a <= kMaxAge; a++) Center(child: Text(localNum(widget.state, a), style: gameText(40, color: GC.gold)))],
            ),
          ]),
        ),
      );
}

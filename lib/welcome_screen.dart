import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_state.dart';
import 'game_ui.dart';
import 'moon_screen.dart';
import 'strings.dart';

/// Shows the age-tier voice: same facts, different wording.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final young = s.tier == Tier.young;
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SpeechBubble(tr(s, 'welcome_${s.tier.name}', vars: {'name': s.name}), size: young ? 24 : 19),
                const Roby(size: 150),
                if (kDebugMode) Padding(padding: const EdgeInsets.only(top: 8), child: Text('[debug] age ${s.age} -> tier: ${s.tier.name}', style: gameText(13, color: Colors.white54, weight: 500))),
                const SizedBox(height: 24),
                SizedBox(width: 280, child: ChunkyButton(label: tr(s, 'launch'), onTap: () => Navigator.of(context).pushReplacement(gameRoute(const MoonScreen())))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

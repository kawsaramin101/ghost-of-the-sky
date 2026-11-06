import 'package:flutter/material.dart';
import 'app_state.dart';
import 'artifact.dart';
import 'game_ui.dart';
import 'strings.dart';

/// Bottom sheet that tells the artifact's story in the user's language and age tier.
class ArtifactSheet extends StatelessWidget {
   const ArtifactSheet({super.key, required this.artifact, this.onNext});
  final Artifact artifact;
  final VoidCallback? onNext;

  Widget _chip(String text, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14), border: Border.all(color: GC.outline, width: 2)),
        child: Text(text, style: gameText(14, color: Colors.white, weight: 700)),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final a = artifact;
    final young = s.tier == Tier.young;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .82),
      decoration: BoxDecoration(
        color: GC.bgBottom,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: GC.gold, width: 4),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 14),
            OutlinedText(a.nameFor(s), size: 34),
            const SizedBox(height: 4),
            Text(a.placeFor(s), textAlign: TextAlign.center, style: gameText(17, color: Colors.white70, weight: 600)),
            const SizedBox(height: 10),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 6, children: [
              _chip(tr(s, 'landed', vars: {'y': localNum(s, a.year)}), GC.violet),
              if (a.lastContact != null) _chip(tr(s, 'last_signal', vars: {'y': localNum(s, a.lastContact!)}), GC.pink),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), borderRadius: BorderRadius.circular(22)),
              child: Text(a.storyFor(s), style: gameText(young ? 21 : 18, color: Colors.white, weight: 600).copyWith(height: 1.35)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: GC.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(20), border: Border.all(color: GC.gold, width: 2)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💡', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr(s, 'did_you_know'), style: gameText(16, color: GC.gold)),
                    const SizedBox(height: 2),
                    Text(a.factFor(s), style: gameText(young ? 18 : 16, color: Colors.white, weight: 600).copyWith(height: 1.3)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: ChunkyButton(label: tr(s, 'close'), color: GC.violet, dark: GC.violetDark, onTap: () => Navigator.of(context).pop())),
              if (onNext != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ChunkyButton(
                    label: tr(s, 'next'), icon: Icons.arrow_forward_rounded, color: GC.orange, dark: GC.orangeDark,
                    onTap: () { onNext!(); Navigator.of(context).pop(); },
                  ),
                ),
              ],
            ]),
          ]),
        ),
      ),
    );
  }
}

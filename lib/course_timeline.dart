import 'package:flutter/material.dart';
import 'app_state.dart';
import 'artifact.dart';
import 'game_ui.dart';
import 'strings.dart';

/// Bottom bar: ◀ [ ●──●·●──●── ] ▶. Big dots = main stops, small dots = glimpses.
class CourseTimeline extends StatefulWidget {
  const CourseTimeline({
    super.key,
    required this.items,
    required this.currentId,
    required this.enabled,
    required this.onSelect,
    this.onPrev,
    this.onNext,
  });
  final List<Artifact> items; // this body's artifacts, already sorted
  final String? currentId;
  final bool enabled;
  final ValueChanged<Artifact> onSelect;
  final VoidCallback? onPrev, onNext;
  @override
  State<CourseTimeline> createState() => _CourseTimelineState();
}

class _CourseTimelineState extends State<CourseTimeline> {
  final _keys = <String, GlobalKey>{};

  @override
  void didUpdateWidget(CourseTimeline old) {
    super.didUpdateWidget(old);
    final id = widget.currentId;
    if (id != null && id != old.currentId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _keys[id]?.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              alignment: .5);
        }
      });
    }
  }

  Widget _arrow(IconData i, VoidCallback? f) => ChunkyButton(
      icon: i,
      small: true,
      wide: false,
      color: GC.violet,
      dark: GC.violetDark,
      onTap: f);

  Widget _node(AppState s, Artifact a) {
    final cur = a.id == widget.currentId;
    final key = _keys.putIfAbsent(a.id, () => GlobalKey());
    final base = a.body == 'moon' ? GC.orange : GC.pink;
    final d = (a.isMain ? 26.0 : 12.0) + (cur ? 6 : 0);
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? () => widget.onSelect(a) : null,
      child: SizedBox(
        width: a.isMain ? 56 : 32,
        child: Column(children: [
          SizedBox(
            height: 34,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cur ? GC.teal : (a.isMain ? base : Colors.white38),
                  border:
                      Border.all(color: GC.outline, width: a.isMain ? 3 : 2),
                  boxShadow: cur
                      ? [
                          BoxShadow(
                              color: GC.teal.withValues(alpha: .6),
                              blurRadius: 12)
                        ]
                      : null,
                ),
              ),
            ),
          ),
          Text(localNum(s, a.year),
              style: gameText(a.isMain ? 14 : 11,
                  color: cur ? GC.gold : Colors.white70, weight: 700)),
        ]),
      ),
    );
  }

  Widget _link() => SizedBox(
        width: 12,
        height: 34,
        child: Center(
            child: Container(
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)))),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final nodes = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      if (i > 0) nodes.add(_link());
      nodes.add(_node(s, widget.items[i]));
    }
    return Container(
      height:
          88, // fixed height: a horizontal scroll view would otherwise expand to full screen
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 14),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(
        color: GC.bgBottom.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: GC.gold, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), offset: Offset(0, 5))
        ],
      ),
      child: Row(children: [
        _arrow(Icons.arrow_back_rounded, widget.enabled ? widget.onPrev : null),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (_, c) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: c.maxWidth),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nodes),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _arrow(
            Icons.arrow_forward_rounded, widget.enabled ? widget.onNext : null),
      ]),
    );
  }
}

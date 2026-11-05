import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app_state.dart';
import 'game_ui.dart';
import 'onboarding_screen.dart';
import 'strings.dart';

class MoonScreen extends StatefulWidget {
  const MoonScreen({super.key});
  @override
  State<MoonScreen> createState() => _MoonScreenState();
}

class _MoonScreenState extends State<MoonScreen> {
  InAppWebViewController? _web;
  bool _ready = false;
  // Status is a function of app state so it re-translates when the language changes.
  String Function(AppState) _status = (s) => tr(s, 'loading');

  static const _ids = ['apollo11', 'apollo12', 'apollo17'];
  static const _colors = [(GC.orange, GC.orangeDark), (GC.pink, GC.pinkDark), (GC.teal, GC.tealDark)];

  void _say(String Function(AppState) f) {
    if (mounted) setState(() => _status = f);
  }

  // Flutter -> 3D
  Future<void> _focusOn(String id) async {
    if (_ready) await _web?.evaluateJavascript(source: "GhostsBridge.focusOn('$id')");
  }

  Future<void> _resetView() async {
    if (_ready) await _web?.evaluateJavascript(source: 'GhostsBridge.resetView()');
  }

  Future<void> _restart(AppState s) async {
    await s.reset();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(gameRoute(const OnboardingScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      body: Stack(children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri('http://localhost:8080/web/index.html')),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: true, supportZoom: false),
          onWebViewCreated: (c) {
            _web = c;
            // 3D -> Flutter
            c.addJavaScriptHandler(handlerName: 'onSceneReady', callback: (_) {
              _ready = true;
              _say((s) => tr(s, 'ready', vars: {'name': s.name}));
              return null;
            });
            c.addJavaScriptHandler(handlerName: 'onMarkerTapped', callback: (args) {
              final id = args.first as String;
              _say((s) => tr(s, 'tapped', vars: {'x': tr(s, id)}));
              return null;
            });
            c.addJavaScriptHandler(handlerName: 'onCameraArrived', callback: (args) {
              final id = args.first as String;
              _say((s) => tr(s, 'arrived', vars: {'x': tr(s, id)}));
              return null;
            });
          },
          onConsoleMessage: (c, m) => debugPrint('[JS] ${m.message}'),
          onReceivedError: (c, req, err) => _say((s) => tr(s, 'load_error', vars: {'x': err.description})),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: GC.bgBottom.withValues(alpha: .85), borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: GC.gold, width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x66000000), offset: Offset(0, 5))],
                    ),
                    child: Text(_status(s), style: gameText(17, color: Colors.white, weight: 600)),
                  ),
                ),
                const SizedBox(width: 10),
                ChunkyButton(icon: Icons.person_rounded, small: true, wide: false, color: GC.violet, dark: GC.violetDark, onTap: () => _restart(s)),
              ]),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Wrap(spacing: 10, runSpacing: 14, alignment: WrapAlignment.center, children: [
                for (var i = 0; i < _ids.length; i++)
                  ChunkyButton(label: tr(s, _ids[i]), small: true, wide: false, color: _colors[i].$1, dark: _colors[i].$2, onTap: () => _focusOn(_ids[i])),
                ChunkyButton(icon: Icons.zoom_out_map_rounded, label: tr(s, 'reset'), small: true, wide: false, color: GC.violet, dark: GC.violetDark, onTap: _resetView),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

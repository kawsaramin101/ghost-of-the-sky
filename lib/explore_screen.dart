import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app_state.dart';
import 'artifact.dart';
import 'artifact_sheet.dart';
import 'game_ui.dart';
import 'onboarding_screen.dart';
import 'strings.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.startBody = 'moon', this.startId});
  final String startBody; // 'moon' | 'mars'
  final String? startId; // artifact to fly to and open on arrival
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _palette = [(GC.orange, GC.orangeDark), (GC.pink, GC.pinkDark), (GC.teal, GC.tealDark)];

  InAppWebViewController? _web;
  List<Artifact> _all = [];
  final _loaded = Completer<void>();
  late String _body = widget.startBody;
  String? _pendingOpen; // opened once the planet swap finishes
  String? _focusId; // sheet opens when the camera arrives here
  bool _busy = true, _sheetOpen = false;
  String Function(AppState) _status = (s) => tr(s, 'loading');

  @override
  void initState() {
    super.initState();
    loadArtifacts().then((l) {
      _all = l;
      _loaded.complete();
      if (mounted) setState(() {});
    });
  }

  void _say(String Function(AppState) f) {
    if (mounted) setState(() => _status = f);
  }

  Future<void> _js(String code) async => _web?.evaluateJavascript(source: code);

  // Flutter -> 3D
  Future<void> _switchBody(String body, {String? openId}) async {
    _busy = true;
    _pendingOpen = openId;
    setState(() => _body = body);
    _say((s) => tr(s, body == 'mars' ? 'to_mars' : 'to_moon'));
    final sites = [
      for (final a in _all.where((x) => x.body == body)) {'id': a.id, 'lat': a.lat, 'lon': a.lon},
    ];
    await _js('GhostsBridge.setBody(${jsonEncode(body)}, ${jsonEncode(sites)})');
  }

  Future<void> _open(String id) async {
    if (_sheetOpen) return;
    _focusId = id;
    await _js("GhostsBridge.focusOn('$id')");
  }

  Future<void> _showSheet(String id) async {
    if (_sheetOpen || !mounted) return;
    final a = _all.firstWhere((x) => x.id == id);
    _sheetOpen = true;
    _focusId = null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ArtifactSheet(artifact: a),
    );
    _sheetOpen = false;
  }

  Future<void> _restart(AppState s) async {
    await s.reset();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(gameRoute(const OnboardingScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final here = _all.where((a) => a.body == _body).toList();
    Widget bodyButton(String b, Color c, Color d) => ChunkyButton(
          label: tr(s, b), small: true, wide: false,
          color: _body == b ? c : GC.grey, dark: _body == b ? d : GC.greyDark,
          onTap: (_busy || _body == b) ? null : () => _switchBody(b),
        );
    return Scaffold(
      body: Stack(children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri('http://localhost:8080/web/index.html')),
          initialSettings: InAppWebViewSettings(javaScriptEnabled: true, supportZoom: false),
          onWebViewCreated: (c) {
            _web = c;
            // 3D -> Flutter
            c.addJavaScriptHandler(handlerName: 'onSceneReady', callback: (_) async {
              await _loaded.future;
              await _switchBody(widget.startBody, openId: widget.startId);
              return null;
            });
            c.addJavaScriptHandler(handlerName: 'onBodyReady', callback: (_) {
              _busy = false;
              _say((s) => tr(s, 'ready', vars: {'name': s.name}));
              final id = _pendingOpen;
              _pendingOpen = null;
              if (id != null) _open(id);
              if (mounted) setState(() {});
              return null;
            });
            c.addJavaScriptHandler(handlerName: 'onMarkerTapped', callback: (args) {
              _open(args.first as String);
              return null;
            });
            c.addJavaScriptHandler(handlerName: 'onCameraArrived', callback: (args) {
              final id = args.first as String;
              if (id == _focusId) _showSheet(id);
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
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
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
                const SizedBox(height: 14),
                Row(children: [
                  bodyButton('moon', GC.orange, GC.orangeDark),
                  const SizedBox(width: 10),
                  bodyButton('mars', GC.pink, GC.pinkDark),
                  const SizedBox(width: 10),
                  ChunkyButton(icon: Icons.zoom_out_map_rounded, small: true, wide: false, color: GC.violet, dark: GC.violetDark, onTap: _busy ? null : () => _js('GhostsBridge.resetView()')),
                ]),
              ]),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 78,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                children: [
                  for (var i = 0; i < here.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChunkyButton(
                        label: here[i].nameFor(s), small: true, wide: false,
                        color: _palette[i % 3].$1, dark: _palette[i % 3].$2,
                        onTap: _busy ? null : () => _open(here[i].id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

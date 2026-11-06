import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app_state.dart';
import 'artifact.dart';
import 'artifact_sheet.dart';
import 'course_timeline.dart';
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
  InAppWebViewController? _web;
  List<Artifact> _all = [];
  final _loaded = Completer<void>();
  late String _body = widget.startBody;
  String? _pendingOpen; // opened once the planet swap finishes
  String? _focusId; // sheet opens when the camera arrives here
  String? _curId; // last artifact the camera was sent to (timeline highlight)
  VoidCallback? _afterSheet; // runs once the story sheet has finished closing
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

  // ---- Course order: Moon first, then Mars; by year inside each; file order breaks ties ----
  int _key(Artifact a) =>
      (a.body == 'moon' ? 0 : 1) * 100000000 + a.year * 1000 + _all.indexOf(a);

  List<Artifact> _sorted({bool onlyMain = false, String? body}) => _all
      .where((a) => (!onlyMain || a.isMain) && (body == null || a.body == body))
      .toList()
    ..sort((a, b) => _key(a).compareTo(_key(b)));

  Artifact? get _current => _all.where((a) => a.id == _curId).firstOrNull;

  /// Next (dir > 0) or previous (dir < 0) MAIN stop relative to [from].
  Artifact? _target(int dir, Artifact? from) {
    final course = _sorted(onlyMain: true);
    if (from == null)
      return dir > 0 ? course.where((a) => a.body == _body).firstOrNull : null;
    final k = _key(from);
    return dir > 0
        ? course.where((a) => _key(a) > k).firstOrNull
        : course.where((a) => _key(a) < k).lastOrNull;
  }

  void _goTo(Artifact a) {
    if (_busy || _sheetOpen) return;
    if (a.body != _body) {
      _switchBody(a.body,
          openId: a.id); // Moon <-> Mars: planet swap first, then fly in
    } else {
      _open(a.id);
    }
  }

  // Flutter -> 3D
  Future<void> _switchBody(String body, {String? openId}) async {
    _busy = true;
    _pendingOpen = openId;
    _curId = openId;
    setState(() => _body = body);
    _say((s) => tr(s, body == 'mars' ? 'to_mars' : 'to_moon'));
    final sites = [
      for (final a in _all.where((x) => x.body == body))
        {'id': a.id, 'lat': a.lat, 'lon': a.lon},
    ];
    await _js(
        'GhostsBridge.setBody(${jsonEncode(body)}, ${jsonEncode(sites)})');
  }

  Future<void> _open(String id) async {
    if (_sheetOpen) return;
    _focusId = id;
    if (mounted) setState(() => _curId = id);
    await _js("GhostsBridge.focusOn('$id')");
  }

  Future<void> _showSheet(String id) async {
    if (_sheetOpen || !mounted) return;
    final a = _all.firstWhere((x) => x.id == id);
    final next = _target(1, a);
    _sheetOpen = true;
    _focusId = null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ArtifactSheet(
        artifact: a,
        onNext: next == null ? null : () => _afterSheet = () => _goTo(next),
      ),
    );
    _sheetOpen = false;
    final f = _afterSheet;
    _afterSheet = null;
    if (mounted)
      f?.call(); // e.g. "Next" pressed: fly on once the sheet is gone
  }

  Future<void> _restart(AppState s) async {
    await s.reset();
    if (!mounted) return;
    Navigator.of(context)
        .pushAndRemoveUntil(gameRoute(const OnboardingScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final prev = _target(-1, _current), next = _target(1, _current);
    Widget bodyButton(String b, Color c, Color d) => ChunkyButton(
          label: tr(s, b),
          small: true,
          wide: false,
          color: _body == b ? c : GC.grey,
          dark: _body == b ? d : GC.greyDark,
          onTap: (_busy || _body == b) ? null : () => _switchBody(b),
        );
    return Scaffold(
      body: Stack(children: [
        InAppWebView(
          initialUrlRequest:
              URLRequest(url: WebUri('http://localhost:8080/web/index.html')),
          initialSettings:
              InAppWebViewSettings(javaScriptEnabled: true, supportZoom: false),
          onWebViewCreated: (c) {
            _web = c;
            // 3D -> Flutter
            c.addJavaScriptHandler(
                handlerName: 'onSceneReady',
                callback: (_) async {
                  await _loaded.future;
                  await _switchBody(widget.startBody, openId: widget.startId);
                  return null;
                });
            c.addJavaScriptHandler(
                handlerName: 'onBodyReady',
                callback: (_) {
                  _busy = false;
                  _say((s) => tr(s, 'ready', vars: {'name': s.name}));
                  final id = _pendingOpen;
                  _pendingOpen = null;
                  if (id != null) _open(id);
                  if (mounted) setState(() {});
                  return null;
                });
            c.addJavaScriptHandler(
                handlerName: 'onMarkerTapped',
                callback: (args) {
                  _open(args.first as String);
                  return null;
                });
            c.addJavaScriptHandler(
                handlerName: 'onCameraArrived',
                callback: (args) {
                  final id = args.first as String;
                  if (id == _focusId) _showSheet(id);
                  return null;
                });
          },
          onConsoleMessage: (c, m) => debugPrint('[JS] ${m.message}'),
          onReceivedError: (c, req, err) =>
              _say((s) => tr(s, 'load_error', vars: {'x': err.description})),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: GC.bgBottom.withValues(alpha: .85),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: GC.gold, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x66000000),
                                  offset: Offset(0, 5))
                            ],
                          ),
                          child: Text(_status(s),
                              style: gameText(17,
                                  color: Colors.white, weight: 600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ChunkyButton(
                          icon: Icons.person_rounded,
                          small: true,
                          wide: false,
                          color: GC.violet,
                          dark: GC.violetDark,
                          onTap: () => _restart(s)),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      bodyButton('moon', GC.orange, GC.orangeDark),
                      const SizedBox(width: 10),
                      bodyButton('mars', GC.pink, GC.pinkDark),
                      const SizedBox(width: 10),
                      ChunkyButton(
                          icon: Icons.zoom_out_map_rounded,
                          small: true,
                          wide: false,
                          color: GC.violet,
                          dark: GC.violetDark,
                          onTap: _busy
                              ? null
                              : () => _js('GhostsBridge.resetView()')),
                    ]),
                  ]),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CourseTimeline(
              items: _sorted(body: _body),
              currentId: _curId,
              enabled: !_busy,
              onSelect: _goTo,
              onPrev: prev == null ? null : () => _goTo(prev),
              onNext: next == null ? null : () => _goTo(next),
            ),
          ),
        ),
      ]),
    );
  }
}

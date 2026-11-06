import 'package:flutter/foundation.dart';

/// Where the Three.js scene lives.
///
/// Native: `InAppLocalhostServer` serves the asset bundle on loopback, and
/// `documentRoot: 'assets'` means `assets/web/index.html`.
///
/// Web: the Flutter web host serves the same bundle, but under the
/// `assets/` prefix it already adds, so the file lands at
/// `assets/assets/web/index.html`. Resolved against [Uri.base] so it keeps
/// working when the app is deployed under a sub-path.
String get sceneUrl => kIsWeb
    ? Uri.base.resolve('assets/assets/web/index.html').toString()
    : 'http://localhost:8080/web/index.html';

# ghosts_spike - Day 1 spike
Flutter + Three.js r170 in a WebView (flutter_inappwebview 6.1.5, pinned).

1. `bash setup.sh`   (generates android/, patches the manifest, runs pub get)
2. Plug in a real phone, then `flutter run`
3. Check: Moon shows -> drag rotates -> pinch zooms -> tap an orange dot updates the status bar (3D->Flutter) -> bottom buttons fly the camera (Flutter->3D).

If something breaks, send me: the exact error text, `flutter doctor -v` output, and the phone model.
Fallback if the plugin will not build on Flutter 3.47: `webview_flutter` + a tiny Dart HttpServer serving the assets (ask me).

Placeholder Moon texture is three.js's example image. Use a NASA map (e.g. LROC/SVS) for the real build.


import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'app_state.dart';
import 'game_ui.dart';
import 'explore_screen.dart';
import 'story_intro_screen.dart';

// Serves everything under assets/ at http://localhost:8080/
// Only starts on native platforms (Android/Linux).
final localhostServer = InAppLocalhostServer(
  documentRoot: 'assets',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dart ServerSocket is not supported in browser environments.
  if (!kIsWeb) {
    await localhostServer.start();
  }

  // Load application state.
  final state = await AppState.load();

  // Start the application.
  runApp(
    GhostsApp(
      state: state,
      // Decided once at startup; later navigation is explicit.
      home: state.onboarded
          ? const ExploreScreen()
          : const StoryIntroScreen(),
    ),
  );
}

class GhostsApp extends StatelessWidget {
  const GhostsApp({
    super.key,
    required this.state,
    required this.home,
  });

  final AppState state;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: gameTheme(),
        home: home,
      ),
    );
  }
}

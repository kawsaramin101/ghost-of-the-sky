import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Lang { en, bn }
enum Tier { young, older }

/// Age tiers. Change the cut-off here only.
const int kYoungMaxAge = 9;

/// First supported language in the device's preference list (bn / en); English if none match.
Lang deviceLang() {
  for (final l in PlatformDispatcher.instance.locales) {
    if (l.languageCode == 'bn') return Lang.bn;
    if (l.languageCode == 'en') return Lang.en;
  }
  return Lang.en;
}

class AppState extends ChangeNotifier {
  String name = '';
  int age = 10;
  Lang lang = Lang.en;
  bool onboarded = false;

  Tier get tier => age <= kYoungMaxAge ? Tier.young : Tier.older;

  static Future<AppState> load() async {
    final p = await SharedPreferences.getInstance();
    final s = AppState();
    final saved = p.getString('lang');
    s.lang = saved == null ? deviceLang() : (saved == 'bn' ? Lang.bn : Lang.en);
    s.name = p.getString('name') ?? '';
    s.age = p.getInt('age') ?? 10;
    s.onboarded = p.getBool('onboarded') ?? false;
    return s;
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', lang.name);
    await p.setString('name', name);
    await p.setInt('age', age);
    await p.setBool('onboarded', onboarded);
  }

  void setLang(Lang l) { lang = l; notifyListeners(); _save(); }

  Future<void> complete(String n, int a) async {
    name = n; age = a; onboarded = true;
    notifyListeners();
    await _save();
  }

  /// Back to onboarding; keeps name/age so the form is pre-filled.
  Future<void> reset() async { onboarded = false; notifyListeners(); await _save(); }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  /// Rebuilds the caller when state changes (use in build).
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  /// No rebuild subscription (use in initState / callbacks).
  static AppState read(BuildContext c) => c.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

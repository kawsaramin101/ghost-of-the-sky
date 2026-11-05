import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'app_state.dart';

/// One abandoned spacecraft / landing site. Data lives in assets/data/artifacts.json.
class Artifact {
  Artifact({
    required this.id, required this.body, required this.lat, required this.lon,
    required this.year, this.lastContact, required this.name, required this.place,
    required this.story, required this.fact,
  });

  final String id, body; // body: 'moon' | 'mars'
  final double lat, lon; // degrees, east positive
  final int year;
  final int? lastContact;
  final Map<String, String> name, place, fact; // keyed by 'en' / 'bn'
  final Map<String, Map<String, String>> story; // lang -> tier ('young'/'older') -> text

  factory Artifact.fromJson(Map<String, dynamic> j) => Artifact(
        id: j['id'] as String,
        body: j['body'] as String,
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
        year: j['year'] as int,
        lastContact: j['lastContact'] as int?,
        name: Map<String, String>.from(j['name'] as Map),
        place: Map<String, String>.from(j['place'] as Map),
        fact: Map<String, String>.from(j['fact'] as Map),
        story: (j['story'] as Map).map((k, v) => MapEntry(k as String, Map<String, String>.from(v as Map))),
      );

  String nameFor(AppState s) => name[s.lang.name]!;
  String placeFor(AppState s) => place[s.lang.name]!;
  String factFor(AppState s) => fact[s.lang.name]!;
  String storyFor(AppState s) => story[s.lang.name]![s.tier.name]!;
}

Future<List<Artifact>> loadArtifacts() async {
  final raw = await rootBundle.loadString('assets/data/artifacts.json');
  return (jsonDecode(raw) as List).map((e) => Artifact.fromJson(e as Map<String, dynamic>)).toList();
}

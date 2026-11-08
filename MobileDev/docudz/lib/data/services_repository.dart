// Mock content repository.
//
// v1 plan: the bundled JSON seeds a local SQLite database on first launch
// (sqflite), and content updates replace it. For this UI deliverable the
// screens read the same JSON straight into memory, which keeps the UI layer
// identical: screens only ever talk to [Catalog].
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

class ServicesRepository {
  const ServicesRepository({this.assetPath = 'assets/data/services.json'});

  final String assetPath;

  Future<Catalog> load(AssetBundle bundle) async {
    final raw = await bundle.loadString(assetPath);
    return parse(raw);
  }

  static Catalog parse(String raw) => Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

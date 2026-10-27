import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/menu.dart';

class MenuService {
  // Returns null when there is no menu for this id (wrong or old QR).
  static Future<Restaurant?> load(String id) async {
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(id)) return null;

    final path = 'assets/menus/$id.json';
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    if (!manifest.listAssets().contains(path)) return null;

    final raw = await rootBundle.loadString(path, cache: false);
    return Restaurant.fromJson(jsonDecode(raw));
  }
}

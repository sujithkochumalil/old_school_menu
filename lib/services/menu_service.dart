import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu.dart';

class MenuService {
  // Emits null when there is no menu for this id (wrong or old QR).
  static Stream<Restaurant?> watch(String id) {
    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(id)) return Stream.value(null);

    final ref = FirebaseFirestore.instance.collection('restaurants').doc(id);
    final subs = <StreamSubscription>[];
    DocumentSnapshot<Map<String, dynamic>>? info;
    QuerySnapshot<Map<String, dynamic>>? categories;
    QuerySnapshot<Map<String, dynamic>>? items;
    late final StreamController<Restaurant?> controller;

    void emit() {
      final i = info, c = categories, m = items;
      if (i == null || c == null || m == null) return;
      controller.add(i.exists ? _build(i, c, m) : null);
    }

    controller = StreamController(
      onListen: () => subs.addAll([
        ref.snapshots().listen((s) {
          info = s;
          emit();
        }, onError: controller.addError),
        ref.collection('categories').snapshots().listen((s) {
          categories = s;
          emit();
        }, onError: controller.addError),
        ref.collection('items').snapshots().listen((s) {
          items = s;
          emit();
        }, onError: controller.addError),
      ]),
      onCancel: () => Future.wait(subs.map((s) => s.cancel())),
    );
    return controller.stream;
  }

  static Restaurant _build(
    DocumentSnapshot<Map<String, dynamic>> doc,
    QuerySnapshot<Map<String, dynamic>> categories,
    QuerySnapshot<Map<String, dynamic>> items,
  ) {
    final byCategory = <String, List<MenuItem>>{};
    for (final d in items.docs) {
      final item = MenuItem.fromFirestore(d);
      byCategory.putIfAbsent(item.categoryId, () => []).add(item);
    }
    final list = [
      for (final d in categories.docs)
        MenuCategory.fromFirestore(
          d,
          (byCategory[d.id] ?? [])..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
        ),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Restaurant.fromFirestore(doc, list);
  }
}

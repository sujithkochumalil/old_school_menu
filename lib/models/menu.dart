import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final String tagline;
  final String logo;
  final String address;
  final String phone;
  final String opens;
  final String closes;
  final String currency;
  final List<MenuCategory> categories;

  Restaurant({
    required this.id,
    required this.name,
    required this.tagline,
    required this.logo,
    required this.address,
    required this.phone,
    required this.opens,
    required this.closes,
    required this.currency,
    required this.categories,
  });

  factory Restaurant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<MenuCategory> categories,
  ) {
    final data = doc.data() ?? {};
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      tagline: data['tagline'] ?? '',
      logo: data['logo'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      opens: data['opens'] ?? '',
      closes: data['closes'] ?? '',
      currency: data['currency'] ?? '₹',
      categories: categories,
    );
  }

  // null when timings are not set
  bool? get isOpenNow {
    final open = _minutes(opens);
    final close = _minutes(closes);
    if (open == null || close == null) return null;
    final now = DateTime.now();
    final current = now.hour * 60 + now.minute;
    if (open < close) return current >= open && current < close;
    return current >= open || current < close;
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.sortOrder = 0,
    required this.items,
  });

  factory MenuCategory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<MenuItem> items,
  ) {
    final data = doc.data() ?? {};
    return MenuCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      sortOrder: _int(data['sortOrder']),
      items: items,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String desc;
  final num price;
  final bool veg;
  final bool available;
  final String tag;
  final String image;
  final String categoryId;
  final int sortOrder;

  MenuItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.veg,
    required this.available,
    required this.tag,
    required this.image,
    required this.categoryId,
    required this.sortOrder,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final price = data['price'];
    return MenuItem(
      id: doc.id,
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      price: price is num ? price : 0,
      veg: data['veg'] ?? true,
      available: data['available'] ?? true,
      tag: data['tag'] ?? '',
      image: data['image'] ?? '',
      categoryId: data['categoryId'] ?? '',
      sortOrder: _int(data['sortOrder']),
    );
  }

  String priceText(String currency) {
    if (price % 1 == 0) return '$currency${price.toInt()}';
    return '$currency${price.toStringAsFixed(2)}';
  }
}

int _int(Object? value) => value is num ? value.toInt() : 0;

int? _minutes(String time) {
  final parts = time.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

// "22:00" -> "10 PM", "07:30" -> "7:30 AM"
String formatTime(String time) {
  final total = _minutes(time);
  if (total == null) return time;
  final h = total ~/ 60;
  final m = total % 60;
  final hour = h % 12 == 0 ? 12 : h % 12;
  final suffix = h < 12 ? 'AM' : 'PM';
  if (m == 0) return '$hour $suffix';
  return '$hour:${m.toString().padLeft(2, '0')} $suffix';
}

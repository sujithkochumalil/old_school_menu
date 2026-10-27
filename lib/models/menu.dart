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

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as List? ?? [];
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      logo: json['logo'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      opens: json['opens'] ?? '',
      closes: json['closes'] ?? '',
      currency: json['currency'] ?? '₹',
      categories: categories.map((c) => MenuCategory.fromJson(c)).toList(),
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
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    return MenuCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      items: items.map((i) => MenuItem.fromJson(i)).toList(),
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

  MenuItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.veg,
    required this.available,
    required this.tag,
    required this.image,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      price: json['price'] ?? 0,
      veg: json['veg'] ?? true,
      available: json['available'] ?? true,
      tag: json['tag'] ?? '',
      image: json['image'] ?? '',
    );
  }

  String priceText(String currency) {
    if (price % 1 == 0) return '$currency${price.toInt()}';
    return '$currency${price.toStringAsFixed(2)}';
  }
}

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

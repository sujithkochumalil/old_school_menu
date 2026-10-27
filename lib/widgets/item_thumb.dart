import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../theme/app_colors.dart';

const thumbTints = [
  Color(0xFFF3E1CC),
  Color(0xFFEFE0D6),
  Color(0xFFE7E1CF),
  Color(0xFFDDE6DD),
  Color(0xFFF2E6C9),
];

IconData categoryIcon(String key) {
  if (key == 'tea') return Icons.emoji_food_beverage_rounded;
  if (key == 'special') return Icons.local_cafe_rounded;
  if (key == 'coffee') return Icons.coffee_rounded;
  if (key == 'cold') return Icons.local_drink_rounded;
  if (key == 'snack') return Icons.bakery_dining_rounded;
  return Icons.restaurant_menu_rounded;
}

class ItemThumb extends StatelessWidget {
  final MenuItem item;
  final IconData icon;
  final Color tint;
  final double width;
  final double height;
  final double radius;
  final double iconSize;

  const ItemThumb({
    super.key,
    required this.item,
    required this.icon,
    required this.tint,
    required this.width,
    required this.height,
    this.radius = 16,
    this.iconSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = _placeholder();
    if (item.image.startsWith('http')) {
      child = Image.network(
        item.image,
        fit: BoxFit.cover,
        frameBuilder: _whileLoading,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    } else if (item.image.isNotEmpty) {
      child = Image.asset(
        item.image,
        fit: BoxFit.cover,
        frameBuilder: _whileLoading,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }

  // icon tile until the photo has downloaded
  Widget _whileLoading(BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
    if (frame == null && !wasSynchronouslyLoaded) return _placeholder();
    return child;
  }

  Widget _placeholder() {
    return Container(
      color: tint,
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: AppColors.brownLight),
    );
  }
}

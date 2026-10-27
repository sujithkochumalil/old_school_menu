import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class VegMark extends StatelessWidget {
  final bool veg;
  final double size;

  const VegMark({super.key, required this.veg, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final color = veg ? AppColors.veg : AppColors.nonVeg;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        width: size * 0.45,
        height: size * 0.45,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  final String text;

  const TagPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: textStyle(9.5, weight: FontWeight.w800, color: AppColors.tagText),
      ),
    );
  }
}

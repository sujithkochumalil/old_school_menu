import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class MenuHeader extends StatelessWidget {
  final Restaurant menu;
  final String? table;

  const MenuHeader({super.key, required this.menu, this.table});

  @override
  Widget build(BuildContext context) {
    final open = menu.isOpenNow;
    final hasTable = table != null && table!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [AppColors.brown, AppColors.brownLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -36,
              bottom: -44,
              child: Icon(
                Icons.emoji_food_beverage_rounded,
                size: 210,
                color: AppColors.creamGhost,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _logo(),
                      const Spacer(),
                      if (hasTable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restaurant_rounded, size: 15, color: AppColors.ink),
                              const SizedBox(width: 6),
                              Text(
                                'Table $table',
                                style: textStyle(12.5, weight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(menu.name, style: titleStyle(32, color: AppColors.cream)),
                  if (menu.tagline.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      menu.tagline,
                      style: textStyle(14, color: AppColors.creamFaded, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (open != null) _status(open),
                      if (menu.address.isNotEmpty)
                        _pill(
                          Icons.place_rounded,
                          menu.address,
                          AppColors.creamSoft,
                          AppColors.cream,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    if (menu.logo.startsWith('http')) {
      return ClipOval(
        child: Image.network(menu.logo, width: 52, height: 52, fit: BoxFit.cover),
      );
    }
    if (menu.logo.isNotEmpty) {
      return ClipOval(
        child: Image.asset(menu.logo, width: 52, height: 52, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
      child: const Icon(Icons.emoji_food_beverage_rounded, color: AppColors.brown, size: 26),
    );
  }

  Widget _status(bool open) {
    final text = open
        ? 'Open now · Closes ${formatTime(menu.closes)}'
        : 'Closed · Opens ${formatTime(menu.opens)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: open ? AppColors.open : AppColors.closed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: textStyle(12.5, weight: FontWeight.w600, color: AppColors.cream)),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle(12.5, weight: FontWeight.w700, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

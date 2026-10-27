import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'badges.dart';
import 'item_thumb.dart';

class ItemTile extends StatelessWidget {
  final MenuItem item;
  final IconData icon;
  final Color tint;
  final String currency;
  final VoidCallback onTap;

  const ItemTile({
    super.key,
    required this.item,
    required this.icon,
    required this.tint,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: item.available ? 1 : 0.55,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          child: Material(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemThumb(item: item, icon: icon, tint: tint, width: 88, height: 88),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              VegMark(veg: item.veg),
                              if (item.tag.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                TagPill(text: item.tag),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(16, weight: FontWeight.w700),
                          ),
                          if (item.desc.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle(12.5, color: AppColors.muted, height: 1.4),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                item.priceText(currency),
                                style: textStyle(16, weight: FontWeight.w800),
                              ),
                              const Spacer(),
                              if (!item.available)
                                Text(
                                  'Sold out',
                                  style: textStyle(12, weight: FontWeight.w700, color: AppColors.nonVeg),
                                )
                              else
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppColors.chipBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: AppColors.brown,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PopularCard extends StatelessWidget {
  final MenuItem item;
  final IconData icon;
  final Color tint;
  final String currency;
  final VoidCallback onTap;

  const PopularCard({
    super.key,
    required this.item,
    required this.icon,
    required this.tint,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 156,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemThumb(
                item: item,
                icon: icon,
                tint: tint,
                width: 136,
                height: 104,
                radius: 14,
                iconSize: 40,
              ),
              const SizedBox(height: 10),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle(14, weight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  VegMark(veg: item.veg, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    item.priceText(currency),
                    style: textStyle(14, weight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

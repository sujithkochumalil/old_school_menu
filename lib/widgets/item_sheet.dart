import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'badges.dart';
import 'item_thumb.dart';

void showItemSheet(
  BuildContext context, {
  required MenuItem item,
  required IconData icon,
  required Color tint,
  required String currency,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => ItemSheet(item: item, icon: icon, tint: tint, currency: currency),
  );
}

class ItemSheet extends StatelessWidget {
  final MenuItem item;
  final IconData icon;
  final Color tint;
  final String currency;

  const ItemSheet({
    super.key,
    required this.item,
    required this.icon,
    required this.tint,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ItemThumb(
              item: item,
              icon: icon,
              tint: tint,
              width: double.infinity,
              height: 210,
              radius: 22,
              iconSize: 72,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                VegMark(veg: item.veg),
                const SizedBox(width: 8),
                Text(
                  item.veg ? 'Veg' : 'Non-veg',
                  style: textStyle(12, weight: FontWeight.w600, color: AppColors.muted),
                ),
                if (item.tag.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  TagPill(text: item.tag),
                ],
                const Spacer(),
                if (!item.available)
                  Text(
                    'Sold out',
                    style: textStyle(13, weight: FontWeight.w700, color: AppColors.nonVeg),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.name, style: titleStyle(26)),
            if (item.desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.desc,
                style: textStyle(15, color: AppColors.muted, height: 1.5),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Text(item.priceText(currency), style: textStyle(26, weight: FontWeight.w800)),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

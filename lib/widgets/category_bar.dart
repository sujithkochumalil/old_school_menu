import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'badges.dart';
import 'item_thumb.dart';

// Sticky bar: search + veg toggle + category chips. Total height is 118.
class CategoryBar extends StatelessWidget {
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final bool vegOnly;
  final VoidCallback onVegToggle;
  final List<MenuCategory> categories;
  final int active;
  final ValueChanged<String> onCategory;
  final ScrollController chipScroll;
  final Map<String, GlobalKey> chipKeys;
  final int resultCount;
  final bool raised;

  const CategoryBar({
    super.key,
    required this.search,
    required this.onSearch,
    required this.vegOnly,
    required this.onVegToggle,
    required this.categories,
    required this.active,
    required this.onCategory,
    required this.chipScroll,
    required this.chipKeys,
    required this.resultCount,
    required this.raised,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: raised
            ? const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6))]
            : const [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(child: _searchField()),
                const SizedBox(width: 10),
                _vegToggle(),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: search.text.trim().isNotEmpty ? _resultText() : _chips(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _searchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.line),
    );
    return SizedBox(
      height: 48,
      child: TextField(
        controller: search,
        onChanged: onSearch,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.brown,
        style: textStyle(14),
        decoration: InputDecoration(
          hintText: 'Search the menu',
          hintStyle: textStyle(14, color: AppColors.muted),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.muted),
          suffixIcon: search.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                  onPressed: () {
                    search.clear();
                    onSearch('');
                  },
                ),
          filled: true,
          fillColor: AppColors.paper,
          contentPadding: EdgeInsets.zero,
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.brown, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _vegToggle() {
    return InkWell(
      onTap: onVegToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: vegOnly ? AppColors.vegBg : AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: vegOnly ? AppColors.veg : AppColors.line,
            width: vegOnly ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VegMark(veg: true),
            const SizedBox(width: 8),
            Text(
              'Veg',
              style: textStyle(
                13,
                weight: FontWeight.w700,
                color: vegOnly ? AppColors.veg : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultText() {
    final label = resultCount == 1 ? '1 item found' : '$resultCount items found';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: textStyle(13, weight: FontWeight.w600, color: AppColors.muted)),
      ),
    );
  }

  Widget _chips() {
    return SingleChildScrollView(
      controller: chipScroll,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(categories[i], i == active),
            ),
        ],
      ),
    );
  }

  Widget _chip(MenuCategory c, bool selected) {
    return InkWell(
      key: chipKeys.putIfAbsent(c.id, () => GlobalKey()),
      onTap: () => onCategory(c.id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown : AppColors.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.brown : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIcon(c.icon),
              size: 16,
              color: selected ? AppColors.amber : AppColors.brownLight,
            ),
            const SizedBox(width: 6),
            Text(
              c.name,
              style: textStyle(
                13,
                weight: FontWeight.w700,
                color: selected ? AppColors.cream : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

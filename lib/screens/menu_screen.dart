import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/menu.dart';
import '../services/menu_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/category_bar.dart';
import '../widgets/item_sheet.dart';
import '../widgets/item_thumb.dart';
import '../widgets/item_tile.dart';
import '../widgets/menu_header.dart';
import 'not_found_screen.dart';

const double barHeight = 118;

class MenuScreen extends StatefulWidget {
  final String restaurantId;
  final String? table;

  const MenuScreen({super.key, required this.restaurantId, this.table});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _scroll = ScrollController();
  final _chipScroll = ScrollController();
  final _search = TextEditingController();
  final _viewKey = GlobalKey();
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, GlobalKey> _chipKeys = {};

  Restaurant? _menu;
  bool _loading = true;
  String? _error;
  String _query = '';
  bool _vegOnly = false;
  int _active = 0;
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _chipScroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final menu = await MenuService.load(widget.restaurantId);
      if (!mounted) return;
      setState(() {
        _menu = menu;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Please check your internet and try again.';
        _loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  void _onSearch(String value) {
    setState(() => _query = value.trim().toLowerCase());
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _toggleVeg() {
    setState(() => _vegOnly = !_vegOnly);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  // Categories after the veg filter. Empty categories are hidden.
  List<MenuCategory> _visibleCategories() {
    final menu = _menu;
    if (menu == null) return [];
    final list = <MenuCategory>[];
    for (final c in menu.categories) {
      final items = c.items.where((i) => !_vegOnly || i.veg).toList();
      if (items.isEmpty) continue;
      list.add(MenuCategory(id: c.id, name: c.name, icon: c.icon, items: items));
    }
    return list;
  }

  Color _tint(MenuCategory c) {
    final index = _menu!.categories.indexWhere((x) => x.id == c.id);
    return thumbTints[index % thumbTints.length];
  }

  // Distance from the top of the scroll view to the top of a section.
  double? _sectionTop(String id) {
    final box = _sectionKeys[id]?.currentContext?.findRenderObject() as RenderBox?;
    final view = _viewKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || view == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero, ancestor: view).dy;
  }

  void _onScroll() {
    if (_jumping || _query.isNotEmpty || !_scroll.hasClients) return;
    final cats = _visibleCategories();
    if (cats.isEmpty) return;

    var active = 0;
    for (var i = 0; i < cats.length; i++) {
      final top = _sectionTop(cats[i].id);
      if (top != null && top <= barHeight + 40) active = i;
    }
    final pos = _scroll.position;
    if (pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent - 2) {
      active = cats.length - 1;
    }
    if (active == _active) return;

    setState(() => _active = active);
    _centerChip(cats[active].id);
  }

  Future<void> _jumpTo(String id) async {
    final cats = _visibleCategories();
    final index = cats.indexWhere((c) => c.id == id);
    final top = _sectionTop(id);
    if (index < 0 || top == null || !_scroll.hasClients) return;

    setState(() => _active = index);
    _centerChip(id);

    final target = (_scroll.offset + top - barHeight).clamp(0.0, _scroll.position.maxScrollExtent);
    _jumping = true;
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
    _jumping = false;
  }

  void _centerChip(String id) {
    final chip = _chipKeys[id]?.currentContext?.findRenderObject();
    if (chip == null || !_chipScroll.hasClients) return;
    final offset = RenderAbstractViewport.of(chip).getOffsetToReveal(chip, 0.5).offset;
    _chipScroll.animateTo(
      offset.clamp(0.0, _chipScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _openItem(Restaurant menu, MenuCategory c, MenuItem item) {
    showItemSheet(
      context,
      item: item,
      icon: categoryIcon(c.icon),
      tint: _tint(c),
      currency: menu.currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _loadingView();
    if (_error != null) return _errorView();
    final menu = _menu;
    if (menu == null) return const NotFoundScreen();

    final cats = _visibleCategories();
    final searching = _query.isNotEmpty;
    final results = searching ? _searchTiles(menu, cats) : <Widget>[];

    return Title(
      title: menu.name,
      color: AppColors.brown,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: CustomScrollView(
              key: _viewKey,
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: MenuHeader(menu: menu, table: widget.table),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedBar(
                    builder: (raised) => CategoryBar(
                      search: _search,
                      onSearch: _onSearch,
                      vegOnly: _vegOnly,
                      onVegToggle: _toggleVeg,
                      categories: cats,
                      active: _active,
                      onCategory: _jumpTo,
                      chipScroll: _chipScroll,
                      chipKeys: _chipKeys,
                      resultCount: results.length,
                      raised: raised,
                    ),
                  ),
                ),
                if (searching)
                  SliverToBoxAdapter(
                    child: results.isEmpty
                        ? _emptySearch()
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(children: results),
                          ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _popular(menu, cats),
                        for (final c in cats) _section(menu, c),
                      ],
                    ),
                  ),
                SliverToBoxAdapter(child: _footer(menu)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Restaurant menu, MenuCategory c, MenuItem item) {
    return ItemTile(
      item: item,
      icon: categoryIcon(c.icon),
      tint: _tint(c),
      currency: menu.currency,
      onTap: () => _openItem(menu, c, item),
    );
  }

  List<Widget> _searchTiles(Restaurant menu, List<MenuCategory> cats) {
    final tiles = <Widget>[];
    for (final c in cats) {
      for (final item in c.items) {
        final match = item.name.toLowerCase().contains(_query) ||
            item.desc.toLowerCase().contains(_query) ||
            c.name.toLowerCase().contains(_query);
        if (match) tiles.add(_tile(menu, c, item));
      }
    }
    return tiles;
  }

  Widget _popular(Restaurant menu, List<MenuCategory> cats) {
    final cards = <Widget>[];
    for (final c in cats) {
      for (final item in c.items) {
        if (item.tag.toLowerCase() != 'bestseller' || !item.available) continue;
        cards.add(PopularCard(
          item: item,
          icon: categoryIcon(c.icon),
          tint: _tint(c),
          currency: menu.currency,
          onTap: () => _openItem(menu, c, item),
        ));
      }
    }
    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Text('Popular right now', style: titleStyle(22)),
        ),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => cards[index],
          ),
        ),
      ],
    );
  }

  Widget _section(Restaurant menu, MenuCategory c) {
    final count = c.items.length;
    return Padding(
      key: _sectionKeys.putIfAbsent(c.id, () => GlobalKey()),
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(c.name, style: titleStyle(22)),
              const SizedBox(width: 10),
              Text(
                count == 1 ? '1 item' : '$count items',
                style: textStyle(12, weight: FontWeight.w600, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in c.items) _tile(menu, c, item),
        ],
      ),
    );
  }

  Widget _emptySearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 44, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            'Nothing matches "${_search.text.trim()}"',
            textAlign: TextAlign.center,
            style: textStyle(15, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _footer(Restaurant menu) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
      child: Column(
        children: [
          if (menu.phone.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:${menu.phone}')),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text('Call ${menu.name}'),
              ),
            ),
          if (menu.address.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              menu.address,
              textAlign: TextAlign.center,
              style: textStyle(13, weight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Prices may change. Please ask our staff about allergens.',
            textAlign: TextAlign.center,
            style: textStyle(12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _loadingView() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.brown),
            ),
            const SizedBox(height: 16),
            Text('Loading menu…', style: textStyle(14, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.muted),
              const SizedBox(height: 16),
              Text('Something went wrong', style: titleStyle(22)),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: textStyle(14, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _retry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedBar extends SliverPersistentHeaderDelegate {
  final Widget Function(bool raised) builder;

  _PinnedBar({required this.builder});

  @override
  double get minExtent => barHeight;

  @override
  double get maxExtent => barHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: barHeight, child: builder(shrinkOffset > 0));
  }

  @override
  bool shouldRebuild(_PinnedBar oldDelegate) => true;
}

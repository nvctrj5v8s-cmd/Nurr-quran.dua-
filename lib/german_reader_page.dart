import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Deutsches Quran-Seiten-Leser (LTR, Bildbasiert)
/// 
/// Zeigt das deutsche Quran-PDF als Bilder (assets/assets/german_pages/).
/// Genau wie der arabische Mushaf-Reader, aber LTR.
class GermanReaderPage extends StatefulWidget {
  final Color themeColor;

  const GermanReaderPage({
    super.key,
    this.themeColor = Colors.teal,
  });

  @override
  State<GermanReaderPage> createState() => _GermanReaderPageState();
}

class _GermanReaderPageState extends State<GermanReaderPage> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showUI = true;

  static const int totalPages = 1236;
  static const String _savedPageKey = 'german_last_page';
  static const String _bookmarksKey = 'german_quran_bookmarks_v1';
  Map<String, List<int>> _bookmarks = {};

  int _displayPageNumber(int physicalPage) {
    if (physicalPage <= 1208) {
      return (physicalPage + 1) ~/ 2;
    }
    return physicalPage - 604;
  }

  int _physicalPageFromDisplay(int displayPage) {
    if (displayPage <= 604) {
      return (displayPage * 2) - 1;
    }
    return displayPage + 604;
  }

  int get _currentDisplayPage => _displayPageNumber(_currentPage);
  int get _maxDisplayPage => _displayPageNumber(totalPages);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSavedPage();
    _loadBookmarks();
  }

  Future<void> _loadSavedPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_savedPageKey) ?? 1;
      final page = saved.clamp(1, totalPages);
      if (!mounted) return;
      setState(() => _currentPage = page);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(page - 1);
          _preloadPages(page);
        }
      });
    } catch (_) {}
  }

  Future<void> _savePage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_savedPageKey, _currentPage);
    } catch (_) {}
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_bookmarksKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return;
      }

      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      if (!mounted) {
        return;
      }

      setState(() {
        _bookmarks = decoded.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((entry) => (entry as num).toInt()).toList(),
          ),
        );
      });
    } catch (_) {}
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_bookmarksKey, json.encode(_bookmarks));
    } catch (_) {}
  }

  bool _isPageBookmarked(int page) =>
      _bookmarks.values.any((pages) => pages.contains(page));

  void _showSaveBookmarkSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GermanBookmarkSaveSheet(
        currentPage: _currentPage,
        bookmarks: Map<String, List<int>>.from(
          _bookmarks.map((key, value) => MapEntry(key, List<int>.from(value))),
        ),
        themeColor: widget.themeColor,
        onSave: (updated) {
          setState(() => _bookmarks = updated);
          _saveBookmarks();
        },
      ),
    );
  }

  void _showBookmarksPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _GermanBookmarksViewPage(
          bookmarks: Map<String, List<int>>.from(
            _bookmarks.map((key, value) => MapEntry(key, List<int>.from(value))),
          ),
          themeColor: widget.themeColor,
          onNavigateToPage: (page) {
            Navigator.pop(context);
            _pageController.jumpToPage(page - 1);
            setState(() => _currentPage = page);
          },
          onBookmarksUpdated: (updated) {
            setState(() => _bookmarks = updated);
            _saveBookmarks();
          },
        ),
      ),
    );
  }

  void _preloadPages(int page) {
    for (final p in [page - 1, page, page + 1]) {
      if (p >= 1 && p <= totalPages) {
        final imagePath = 'assets/assets/german_pages/${p.toString().padLeft(4, '0')}.jpg';
        final mq = MediaQuery.of(context);
        final targetWidth =
            (mq.size.width * mq.devicePixelRatio).clamp(600.0, 1600.0).round();
        precacheImage(ResizeImage(AssetImage(imagePath), width: targetWidth), context);
      }
    }
  }

  String _imagePath(int page) =>
      'assets/assets/german_pages/${page.toString().padLeft(4, '0')}.jpg';

  void _goToNext() {
    if (_currentPage < totalPages) {
      _pageController.animateToPage(
        _currentPage, // page - 1 + 1 = page (next page index)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrev() {
    if (_currentPage > 1) {
      _pageController.animateToPage(
        _currentPage - 2, // page - 1 - 1
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showPageJumpDialog() {
    final ctrl = TextEditingController(text: '$_currentDisplayPage');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Zu Seite springen'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Seite (1–$_maxDisplayPage)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.tag),
          ),
          onSubmitted: (_) => _jumpToPage(ctrl.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _jumpToPage(ctrl.text),
            child: const Text('Los'),
          ),
        ],
      ),
    );
  }

  void _jumpToPage(String input) {
    final displayPage = int.tryParse(input);
    if (displayPage == null || displayPage < 1 || displayPage > _maxDisplayPage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte Zahl zwischen 1 und $_maxDisplayPage eingeben'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final page = _physicalPageFromDisplay(displayPage).clamp(1, totalPages);
    _pageController.jumpToPage(page - 1);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showUI = !_showUI),
          child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: totalPages,
            pageController: _pageController,
            scrollDirection: Axis.horizontal,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (_, __) => const SizedBox.shrink(),
            onPageChanged: (index) {
              setState(() => _currentPage = index + 1);
              _savePage();
              _preloadPages(index + 1);
            },
            builder: (context, index) {
              final page = index + 1;
              final imagePath = _imagePath(page);
              final mq = MediaQuery.of(context);
              final targetWidth =
                  (mq.size.width * mq.devicePixelRatio).clamp(600.0, 1600.0).round();
              return PhotoViewGalleryPageOptions(
                imageProvider: ResizeImage(AssetImage(imagePath), width: targetWidth),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                filterQuality: FilterQuality.low,
                heroAttributes: PhotoViewHeroAttributes(tag: 'german_page_$page'),
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Seite $page konnte nicht geladen werden',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_showUI) ...[
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: widget.themeColor,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.menu_book, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '📖 Quran auf Deutsch – Seite $_currentDisplayPage',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPageBookmarked(_currentPage)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                        tooltip: 'Seite speichern',
                        onPressed: _showSaveBookmarkSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmarks, color: Colors.white),
                        tooltip: 'Lesezeichen',
                        onPressed: _showBookmarksPage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        tooltip: 'Zur Seite springen',
                        onPressed: _showPageJumpDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(
                    icon: Icons.arrow_back,
                    label: 'Zurück',
                    onPressed: _currentPage > 1 ? _goToPrev : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_currentDisplayPage / $_maxDisplayPage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.themeColor,
                      ),
                    ),
                  ),
                  _navButton(
                    icon: Icons.arrow_forward,
                    label: 'Weiter',
                    onPressed: _currentPage < totalPages ? _goToNext : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.white : Colors.grey.shade400,
        foregroundColor: enabled ? widget.themeColor : Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: enabled ? 2 : 0,
      ),
    );
  }
}

class _GermanBookmarkSaveSheet extends StatefulWidget {
  final int currentPage;
  final Map<String, List<int>> bookmarks;
  final Color themeColor;
  final void Function(Map<String, List<int>>) onSave;

  const _GermanBookmarkSaveSheet({
    required this.currentPage,
    required this.bookmarks,
    required this.themeColor,
    required this.onSave,
  });

  @override
  State<_GermanBookmarkSaveSheet> createState() => _GermanBookmarkSaveSheetState();
}

class _GermanBookmarkSaveSheetState extends State<_GermanBookmarkSaveSheet> {
  late Map<String, List<int>> _local;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _local = Map<String, List<int>>.from(
      widget.bookmarks.map((key, value) => MapEntry(key, List<int>.from(value))),
    );
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _toggle(String category) {
    setState(() {
      final pages = _local[category]!;
      if (pages.contains(widget.currentPage)) {
        pages.remove(widget.currentPage);
      } else {
        pages.add(widget.currentPage);
        pages.sort();
      }
    });
  }

  void _addCategory() {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() {
      if (!_local.containsKey(name)) {
        _local[name] = [widget.currentPage];
      } else {
        final pages = _local[name]!;
        if (!pages.contains(widget.currentPage)) {
          pages.add(widget.currentPage);
          pages.sort();
        }
      }
      _newCategoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: widget.themeColor.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.bookmark_add, color: widget.themeColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Seite ${widget.currentPage} speichern',
                    style: TextStyle(
                      color: widget.themeColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onSave(_local);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Fertig',
                    style: TextStyle(
                      color: widget.themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          Flexible(
            child: _local.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Neue Kategorie unten hinzufügen',
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _local.keys.length,
                    itemBuilder: (_, index) {
                      final category = _local.keys.elementAt(index);
                      final isChecked = _local[category]!.contains(widget.currentPage);
                      return ListTile(
                        leading: Checkbox(
                          value: isChecked,
                          activeColor: widget.themeColor,
                          checkColor: Colors.black,
                          side: BorderSide(color: widget.themeColor),
                          onChanged: (_) => _toggle(category),
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          '${_local[category]!.length} Seiten',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        onTap: () => _toggle(category),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Name der neuen Kategorie',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Hinzufügen',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GermanBookmarksViewPage extends StatefulWidget {
  final Map<String, List<int>> bookmarks;
  final Color themeColor;
  final void Function(int page) onNavigateToPage;
  final void Function(Map<String, List<int>>) onBookmarksUpdated;

  const _GermanBookmarksViewPage({
    required this.bookmarks,
    required this.themeColor,
    required this.onNavigateToPage,
    required this.onBookmarksUpdated,
  });

  @override
  State<_GermanBookmarksViewPage> createState() => _GermanBookmarksViewPageState();
}

class _GermanBookmarksViewPageState extends State<_GermanBookmarksViewPage> {
  late Map<String, List<int>> _bookmarks;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookmarks = Map<String, List<int>>.from(
      widget.bookmarks.map((key, value) => MapEntry(key, List<int>.from(value))),
    );
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty || _bookmarks.containsKey(name)) {
      return;
    }

    setState(() {
      _bookmarks[name] = [];
      _newCategoryController.clear();
    });
    widget.onBookmarksUpdated(_bookmarks);
  }

  void _removePage(String category, int page) {
    setState(() {
      _bookmarks[category]?.remove(page);
    });
    widget.onBookmarksUpdated(_bookmarks);
  }

  void _removeCategory(String category) {
    setState(() {
      _bookmarks.remove(category);
    });
    widget.onBookmarksUpdated(_bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Lesezeichen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Neue Kategorie',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Hinzufügen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: widget.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _bookmarks.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Noch keine Lesezeichen.\nTippe auf das Lesezeichen-Symbol beim Lesen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: _bookmarks.entries.map((entry) {
                final category = entry.key;
                final pages = entry.value;
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: widget.themeColor.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: ExpansionTile(
                    iconColor: widget.themeColor,
                    collapsedIconColor: widget.themeColor,
                    leading: Icon(Icons.folder_open, color: widget.themeColor),
                    title: Text(
                      category,
                      style: TextStyle(
                        color: widget.themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${pages.length} Seiten',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      tooltip: 'Löschen',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          title: Text(
                            '"$category" löschen?',
                            style: const TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Abbrechen',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _removeCategory(category);
                              },
                              child: const Text(
                                'Löschen',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    children: pages.isEmpty
                        ? const [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Keine Seiten gespeichert',
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ),
                          ]
                        : pages
                            .map(
                              (page) => ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 2,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: widget.themeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: widget.themeColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$page',
                                      style: TextStyle(
                                        color: widget.themeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Seite $page',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => widget.onNavigateToPage(page),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.themeColor,
                                        foregroundColor: Colors.black,
                                        minimumSize: const Size(60, 34),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Öffnen',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white38,
                                        size: 18,
                                      ),
                                      onPressed: () => _removePage(category, page),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

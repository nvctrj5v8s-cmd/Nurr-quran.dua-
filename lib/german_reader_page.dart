import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deutsches Quran-Seiten-Leser (LTR, Bildbasiert)
/// 
/// Zeigt das deutsche Quran-PDF als Bilder (assets/german_pages/).
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSavedPage();
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

  void _preloadPages(int page) {
    for (final p in [page - 1, page, page + 1]) {
      if (p >= 1 && p <= totalPages) {
        final imagePath = 'assets/german_pages/${p.toString().padLeft(4, '0')}.jpg';
        final mq = MediaQuery.of(context);
        final targetWidth =
            (mq.size.width * mq.devicePixelRatio).clamp(600.0, 1600.0).round();
        precacheImage(ResizeImage(AssetImage(imagePath), width: targetWidth), context);
      }
    }
  }

  String _imagePath(int page) =>
      'assets/german_pages/${page.toString().padLeft(4, '0')}.jpg';

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
    final ctrl = TextEditingController(text: '$_currentPage');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Zu Seite springen'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Seite (1–$totalPages)',
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
    final page = int.tryParse(input);
    if (page == null || page < 1 || page > totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte Zahl zwischen 1 und $totalPages eingeben'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
                          '📖 Quran auf Deutsch – Seite $_currentPage',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                      '$_currentPage / $totalPages',
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

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Mushaf Reader - Zeigt Quran-Seiten wie ein gedrucktes Buch
/// 
/// Features:
/// - 604 Seiten als Bilder (PNG/JPG)
/// - RTL: Startseite rechts, Wischen nach links = nächste Seite
/// - Pinch-to-Zoom + Doppeltipp
/// - Speichert letzte Seite
/// - Performance: Caching + Preloading
class MushafReaderPage extends StatefulWidget {
  final Color themeColor;
  final VoidCallback? onShowSurahList;
  final String uiLanguageCode;
  
  const MushafReaderPage({
    super.key,
    this.themeColor = Colors.teal,
    this.onShowSurahList,
    this.uiLanguageCode = 'de',
  });

  @override
  State<MushafReaderPage> createState() => _MushafReaderPageState();
}

class _MushafReaderPageState extends State<MushafReaderPage> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showUI = true;
  static const int _arabicTotalAssetPages = 604;
  static const int _arabicSkippedAssetPages = 2;
  static const int _englishTotalAssetPages = 942;

  // ---- Bookmarks ----
  Map<String, List<int>> _bookmarks = {};

  bool get _isArabicUi => widget.uiLanguageCode == 'ar';
  bool get _isEnglishUi => widget.uiLanguageCode == 'en';
  bool get _isRtlBookLayout => !_isEnglishUi;

  int get _totalPages {
    if (_isEnglishUi) return _englishTotalAssetPages;
    return _arabicTotalAssetPages - _arabicSkippedAssetPages;
  }

  int get _skippedAssetPages {
    if (_isEnglishUi) return 0;
    return _arabicSkippedAssetPages;
  }

  String get _imageFolder {
    if (_isEnglishUi) return 'assets/mushaf_pages_en';
    return 'assets/mushaf_pages';
  }

  String get _savedPageKey {
    if (_isEnglishUi) return 'mushaf_en_last_page';
    return 'mushaf_last_page';
  }

  String get _pageVersionKey {
    if (_isEnglishUi) return 'mushaf_en_page_numbering_version';
    return 'mushaf_page_numbering_version';
  }

  String get _bookmarksKey {
    if (_isEnglishUi) return 'mushaf_en_bookmarks_v1';
    return 'mushaf_bookmarks_v2';
  }

  int get _pageNumberingVersion {
    if (_isEnglishUi) return 1;
    return 2;
  }

  String _titlePrefix() {
    if (_isArabicUi) return 'المصحف - صفحة';
    if (_isEnglishUi) return 'Mushaf - Page';
    return 'Mushaf - Seite';
  }

  String _surahListTooltip() {
    if (_isArabicUi) return 'قائمة السور';
    if (_isEnglishUi) return 'Surah list';
    return 'Surenliste';
  }

  String _jumpTooltip() {
    if (_isArabicUi) return 'الانتقال إلى صفحة';
    if (_isEnglishUi) return 'Jump to page';
    return 'Zur Seite springen';
  }

  String _previousLabel() {
    if (_isArabicUi) return 'السابق';
    if (_isEnglishUi) return 'Previous';
    return 'Zurück';
  }

  String _nextLabel() {
    if (_isArabicUi) return 'التالي';
    if (_isEnglishUi) return 'Next';
    return 'Weiter';
  }

  String _jumpDialogTitle() {
    if (_isArabicUi) return 'إلى صفحة';
    if (_isEnglishUi) return 'Go to page';
    return 'Zu Seite';
  }

  String _pageNumberFieldLabel() {
    if (_isArabicUi) return 'رقم الصفحة (1-$_totalPages)';
    if (_isEnglishUi) return 'Page number (1-$_totalPages)';
    return 'Seitenzahl (1-$_totalPages)';
  }

  String _cancelLabel() {
    if (_isArabicUi) return 'إلغاء';
    if (_isEnglishUi) return 'Cancel';
    return 'Abbrechen';
  }

  String _goLabel() {
    if (_isArabicUi) return 'انتقال';
    if (_isEnglishUi) return 'Go';
    return 'Los';
  }

  String _invalidPageSnackBar() {
    if (_isArabicUi) return 'الرجاء إدخال رقم بين 1 و $_totalPages';
    if (_isEnglishUi) return 'Please enter a number between 1 and $_totalPages';
    return 'Bitte Zahl zwischen 1 und $_totalPages eingeben';
  }

  String _imageLoadError(int visiblePage) {
    if (_isArabicUi) return 'تعذر تحميل الصفحة $visiblePage';
    if (_isEnglishUi) return 'Page $visiblePage could not be loaded';
    return 'Seite $visiblePage konnte nicht geladen werden';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _convertToPhysicalIndex(1));
    _initializeMushaf();
  }

  /// Initialisiere Mushaf sofort ohne separate Warteansicht.
  void _initializeMushaf() {
    _loadSavedPage();
    _loadBookmarks();
  }
  
  Future<void> _loadSavedPage() async {
    int savedPage = 1;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawPage = prefs.getInt(_savedPageKey);
      final version = prefs.getInt(_pageVersionKey) ?? 1;

      if (rawPage != null) {
        savedPage = version >= _pageNumberingVersion
        ? rawPage.clamp(1, _totalPages)
        : (rawPage - 1).clamp(1, _totalPages);
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Seite: $e');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentPage = savedPage;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final physicalIndex = _convertToPhysicalIndex(savedPage);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(physicalIndex);
      }
      _preloadPages(savedPage);
    });
  }
  
  /// Konvertiere sichtbare Seite (1-602) zu physischem Index für RTL.
  int _convertToPhysicalIndex(int visiblePage) {
    if (_isRtlBookLayout) {
      return _totalPages - visiblePage;
    }
    return visiblePage - 1;
  }

  /// Konvertiere physischen Index zu sichtbarer Seite.
  int _convertToLogicalPage(int physicalIndex) {
    if (_isRtlBookLayout) {
      return _totalPages - physicalIndex;
    }
    return physicalIndex + 1;
  }
  
  /// Preload aktuelle Seite + 2 Nachbarn für smooth scrolling
  void _preloadPages(int visiblePage) {
    final pagesToPreload = [
      visiblePage - 1,
      visiblePage,
      visiblePage + 1,
    ];
    
    for (final page in pagesToPreload) {
      if (page >= 1 && page <= _totalPages) {
        final pageNum = _formatPageNumber(page);
        final imagePath = '$_imageFolder/$pageNum.png';
        final mediaQuery = MediaQuery.of(context);
        final targetWidth =
            (mediaQuery.size.width * mediaQuery.devicePixelRatio)
                .clamp(900.0, 1800.0)
                .round();
        // On web, some browsers are more stable with direct AssetImage decode.
        final ImageProvider<Object> imageProvider = kIsWeb
            ? AssetImage(imagePath)
            : ResizeImage(AssetImage(imagePath), width: targetWidth);
        precacheImage(imageProvider, context);
      }
    }
  }
  
  /// Formatiere Seitenzahl für URL
  String _formatPageNumber(int visiblePage) {
    final assetPageNumber = visiblePage + _skippedAssetPages;
    return assetPageNumber.toString().padLeft(3, '0');
  }
  
  /// Speichere aktuelle Seite persistent
  Future<void> _savePage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_savedPageKey, _currentPage);
      await prefs.setInt(_pageVersionKey, _pageNumberingVersion);
    } catch (e) {
      debugPrint('Fehler beim Speichern: $e');
    }
  }

  // ---- Bookmark persistence ----

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_bookmarksKey);
      if (jsonStr != null) {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _bookmarks = decoded.map((k, v) => MapEntry(
              k,
              (v as List).map((e) => (e as num).toInt()).toList(),
            ));
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_bookmarksKey, json.encode(_bookmarks));
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  bool _isPageBookmarked(int page) =>
      _bookmarks.values.any((list) => list.contains(page));

  // ---- Bookmark UI helpers ----

  String _saveBookmarkTooltip() {
    if (_isArabicUi) return 'حفظ الصفحة';
    if (_isEnglishUi) return 'Save page';
    return 'Seite speichern';
  }

  String _viewBookmarksTooltip() {
    if (_isArabicUi) return 'الإشارات المرجعية';
    if (_isEnglishUi) return 'Bookmarks';
    return 'Lesezeichen';
  }

  void _showSaveBookmarkSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookmarkSaveSheet(
        currentPage: _currentPage,
        bookmarks: Map<String, List<int>>.from(
          _bookmarks.map((k, v) => MapEntry(k, List<int>.from(v))),
        ),
        themeColor: widget.themeColor,
        uiLanguageCode: widget.uiLanguageCode,
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
        builder: (_) => _BookmarksViewPage(
          bookmarks: Map<String, List<int>>.from(
            _bookmarks.map((k, v) => MapEntry(k, List<int>.from(v))),
          ),
          themeColor: widget.themeColor,
          uiLanguageCode: widget.uiLanguageCode,
          onNavigateToPage: (page) {
            Navigator.pop(context);
            final idx = _convertToPhysicalIndex(page);
            _pageController.jumpToPage(idx);
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
          child: _buildPageView(),
        ),
        if (_showUI) ...[
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildAppBarOverlay(),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ],
    );
  }
  
  /// Overlay AppBar mit Seitenzahl und Aktionen
  Widget _buildAppBarOverlay() {
    return Container(
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
                  '${_titlePrefix()} $_currentPage',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.onShowSurahList != null)
                IconButton(
                  icon: const Icon(Icons.list, color: Colors.white),
                  tooltip: _surahListTooltip(),
                  onPressed: widget.onShowSurahList,
                ),
              IconButton(
                icon: Icon(
                  _isPageBookmarked(_currentPage)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: Colors.white,
                ),
                tooltip: _saveBookmarkTooltip(),
                onPressed: _showSaveBookmarkSheet,
              ),
              IconButton(
                icon: const Icon(Icons.bookmarks, color: Colors.white),
                tooltip: _viewBookmarksTooltip(),
                onPressed: _showBookmarksPage,
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                tooltip: _jumpTooltip(),
                onPressed: _showPageJumpDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Haupt-PageView mit RTL und Zoom
  Widget _buildPageView() {
    if (kIsWeb) {
      return _buildWebPageView();
    }

    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int physicalIndex) {
        final visiblePage = _convertToLogicalPage(physicalIndex);
        final pageNum = _formatPageNumber(visiblePage);
        final imagePath = '$_imageFolder/$pageNum.png';
        final mediaQuery = MediaQuery.of(context);
        final targetWidth =
            (mediaQuery.size.width * mediaQuery.devicePixelRatio)
                .clamp(900.0, 1800.0)
                .round();
        
        final ImageProvider<Object> imageProvider = kIsWeb
            ? AssetImage(imagePath)
            : ResizeImage(AssetImage(imagePath), width: targetWidth);

        return PhotoViewGalleryPageOptions(
          // Decode at device-appropriate width for better speed/memory.
          imageProvider: imageProvider,
          
          // Start at contained size so horizontal swipe switches pages directly.
          initialScale: PhotoViewComputedScale.contained,
          
          // Keep min at contained to avoid accidental underscale panning.
          minScale: PhotoViewComputedScale.contained,
          
          // Max: 3x zoom
          maxScale: PhotoViewComputedScale.covered * 3.0,

          // Keep rendering lightweight on lower-end devices.
          filterQuality: FilterQuality.low,
          
          // Hero animation für smooth transitions
          heroAttributes: PhotoViewHeroAttributes(
            tag: 'mushaf_page_$visiblePage',
          ),
          
          // Error placeholder
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.brown.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _imageLoadError(visiblePage),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      },
      
      itemCount: _totalPages,
      loadingBuilder: (context, event) {
        return const SizedBox.shrink();
      },
      
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
      
      pageController: _pageController,
      
      // Callback wenn Seite gewechselt wird
      onPageChanged: (physicalIndex) {
        final visiblePage = _convertToLogicalPage(physicalIndex);
        
        setState(() {
          _currentPage = visiblePage;
        });
        
        // Speichere neue Seite
        _savePage();
        
        // Preload Nachbarseiten
        _preloadPages(visiblePage);
      },
      
      scrollDirection: Axis.horizontal,
    );
  }

  Widget _buildWebPageView() {
    return PageView.builder(
      controller: _pageController,
      reverse: _isRtlBookLayout,
      itemCount: _totalPages,
      onPageChanged: (pageIndex) {
        final visiblePage = pageIndex + 1;

        setState(() {
          _currentPage = visiblePage;
        });

        _savePage();
        _preloadPages(visiblePage);
      },
      itemBuilder: (context, pageIndex) {
        final visiblePage = pageIndex + 1;
        final pageNum = _formatPageNumber(visiblePage);
        final imagePath = '$_imageFolder/$pageNum.png';

        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.brown.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _imageLoadError(visiblePage),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  /// Bottom Navigation Bar mit Seitenzahl und Navigation
  Widget _buildBottomBar() {
    return Container(
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
          // Vorherige Seite (nach rechts in RTL)
          _buildNavButton(
            icon: _isRtlBookLayout ? Icons.arrow_forward : Icons.arrow_back,
            label: _previousLabel(),
            onPressed: _currentPage > 1 ? _goToPreviousPage : null,
          ),
          
          // Seitenzahl
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              '$_currentPage / $_totalPages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.themeColor,
              ),
            ),
          ),
          
          // Nächste Seite (nach links in RTL)
          _buildNavButton(
            icon: _isRtlBookLayout ? Icons.arrow_back : Icons.arrow_forward,
            label: _nextLabel(),
            onPressed: _currentPage < _totalPages ? _goToNextPage : null,
          ),
        ],
      ),
    );
  }
  
  /// Navigation Button
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? Colors.white : Colors.grey.shade400,
        foregroundColor: isEnabled ? widget.themeColor : Colors.grey.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isEnabled ? 2 : 0,
      ),
    );
  }
  
  /// Gehe zur nächsten Seite (nach links wischen)
  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      final nextLogicalPage = (_currentPage + 1).clamp(1, _totalPages);
      final nextPhysicalIndex = _convertToPhysicalIndex(nextLogicalPage);
      
      _pageController.animateToPage(
        nextPhysicalIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Gehe zur vorherigen Seite (nach rechts wischen)
  void _goToPreviousPage() {
    if (_currentPage > 1) {
      final prevLogicalPage = (_currentPage - 1).clamp(1, _totalPages);
      final prevPhysicalIndex = _convertToPhysicalIndex(prevLogicalPage);
      
      _pageController.animateToPage(
        prevPhysicalIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Dialog: Springe zu bestimmter Seite
  void _showPageJumpDialog() {
    final controller = TextEditingController(text: '$_currentPage');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_jumpDialogTitle()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: _pageNumberFieldLabel(),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.tag),
          ),
          onSubmitted: (_) => _jumpToPage(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_cancelLabel()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _jumpToPage(controller.text),
            child: Text(_goLabel()),
          ),
        ],
      ),
    );
  }
  
  /// Springe zu eingegebener Seite
  void _jumpToPage(String input) {
    final pageNumber = int.tryParse(input);
    if (pageNumber == null || pageNumber < 1 || pageNumber > _totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_invalidPageSnackBar()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final physicalIndex = _convertToPhysicalIndex(pageNumber);
    _pageController.jumpToPage(physicalIndex);
    Navigator.pop(context);
  }
  
}

// ==================== BOOKMARK SAVE SHEET ====================

class _BookmarkSaveSheet extends StatefulWidget {
  final int currentPage;
  final Map<String, List<int>> bookmarks;
  final Color themeColor;
  final String uiLanguageCode;
  final void Function(Map<String, List<int>>) onSave;

  const _BookmarkSaveSheet({
    required this.currentPage,
    required this.bookmarks,
    required this.themeColor,
    required this.uiLanguageCode,
    required this.onSave,
  });

  @override
  State<_BookmarkSaveSheet> createState() => _BookmarkSaveSheetState();
}

class _BookmarkSaveSheetState extends State<_BookmarkSaveSheet> {
  late Map<String, List<int>> _local;
  final TextEditingController _newCatController = TextEditingController();

  bool get _isAr => widget.uiLanguageCode == 'ar';
  bool get _isEn => widget.uiLanguageCode == 'en';

  String get _title =>
      _isAr ? '\u062d\u0641\u0638 \u0635\u0641\u062d\u0629 ${widget.currentPage}' : _isEn ? 'Save Page ${widget.currentPage}' : 'Seite ${widget.currentPage} speichern';
  String get _newCategoryHint =>
      _isAr ? '\u0627\u0633\u0645 \u0627\u0644\u0641\u0626\u0629 \u0627\u0644\u062c\u062f\u064a\u062f\u0629' : _isEn ? 'New category name' : 'Name der neuen Kategorie';
  String get _addLabel => _isAr ? '\u0625\u0636\u0627\u0641\u0629' : _isEn ? 'Add' : 'Hinzufügen';
  String get _doneLabel => _isAr ? '\u062a\u0645' : _isEn ? 'Done' : 'Fertig';
  String get _noCategoriesHint =>
      _isAr ? '\u0623\u0636\u0641 \u0641\u0626\u0629 \u062c\u062f\u064a\u062f\u0629 \u0623\u062f\u0646\u0627\u0647' : _isEn ? 'Add a new category below' : 'Neue Kategorie unten hinzufügen';

  @override
  void initState() {
    super.initState();
    _local = Map<String, List<int>>.from(
      widget.bookmarks.map((k, v) => MapEntry(k, List<int>.from(v))),
    );
  }

  @override
  void dispose() {
    _newCatController.dispose();
    super.dispose();
  }

  void _toggle(String category) {
    setState(() {
      final list = _local[category]!;
      if (list.contains(widget.currentPage)) {
        list.remove(widget.currentPage);
      } else {
        list.add(widget.currentPage);
        list.sort();
      }
    });
  }

  void _addCategory() {
    final name = _newCatController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      if (!_local.containsKey(name)) {
        _local[name] = [widget.currentPage];
      } else {
        final list = _local[name]!;
        if (!list.contains(widget.currentPage)) {
          list.add(widget.currentPage);
          list.sort();
        }
      }
      _newCatController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: widget.themeColor.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.bookmark_add, color: widget.themeColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _title,
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
                  child: Text(_doneLabel,
                      style: TextStyle(
                          color: widget.themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          // Category list
          Flexible(
            child: _local.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_noCategoriesHint,
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _local.keys.length,
                    itemBuilder: (_, i) {
                      final cat = _local.keys.elementAt(i);
                      final isChecked = _local[cat]!.contains(widget.currentPage);
                      return ListTile(
                        leading: Checkbox(
                          value: isChecked,
                          activeColor: widget.themeColor,
                          checkColor: Colors.black,
                          side: BorderSide(color: widget.themeColor),
                          onChanged: (_) => _toggle(cat),
                        ),
                        title: Text(cat,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        subtitle: Text(
                          '${_local[cat]!.length} ${_isAr ? "\u0635\u0641\u062d\u0629" : _isEn ? "pages" : "Seiten"}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        onTap: () => _toggle(cat),
                      );
                    },
                  ),
          ),
          // Add new category
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _newCategoryHint,
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_addLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== BOOKMARKS VIEW PAGE ====================

class _BookmarksViewPage extends StatefulWidget {
  final Map<String, List<int>> bookmarks;
  final Color themeColor;
  final String uiLanguageCode;
  final void Function(int page) onNavigateToPage;
  final void Function(Map<String, List<int>>) onBookmarksUpdated;

  const _BookmarksViewPage({
    required this.bookmarks,
    required this.themeColor,
    required this.uiLanguageCode,
    required this.onNavigateToPage,
    required this.onBookmarksUpdated,
  });

  @override
  State<_BookmarksViewPage> createState() => _BookmarksViewPageState();
}

class _BookmarksViewPageState extends State<_BookmarksViewPage> {
  late Map<String, List<int>> _bm;
  final TextEditingController _newCatController = TextEditingController();

  bool get _isAr => widget.uiLanguageCode == 'ar';
  bool get _isEn => widget.uiLanguageCode == 'en';

  String get _pageTitle =>
      _isAr ? '\u0627\u0644\u0625\u0634\u0627\u0631\u0627\u062a \u0627\u0644\u0645\u0631\u062c\u0639\u064a\u0629' : _isEn ? 'Bookmarks' : 'Lesezeichen';
  String get _emptyHint =>
      _isAr ? '\u0644\u0627 \u062a\u0648\u062c\u062f \u0625\u0634\u0627\u0631\u0627\u062a \u0628\u0639\u062f.\n\u0627\u0636\u063a\u0637 \u0639\u0644\u0649 \u0632\u0631 \u0627\u0644\u0625\u0634\u0627\u0631\u0629 \u0623\u062b\u0646\u0627\u0621 \u0642\u0631\u0627\u0621\u0629 \u0627\u0644\u0645\u0635\u062d\u0641.'
          : _isEn
              ? 'No bookmarks yet.\nTap the bookmark icon while reading.'
              : 'Noch keine Lesezeichen.\nTippe auf das Lesezeichen-Symbol beim Lesen.';
  String get _newCatHint =>
      _isAr ? '\u0627\u0633\u0645 \u0641\u0626\u0629 \u062c\u062f\u064a\u062f\u0629' : _isEn ? 'New category name' : 'Neue Kategorie';
  String get _addLabel => _isAr ? '\u0625\u0636\u0627\u0641\u0629' : _isEn ? 'Add' : 'Hinzufügen';
  String get _goToPageLabel =>
      _isAr ? '\u0627\u0646\u062a\u0642\u0644' : _isEn ? 'Go' : 'Open';
  String get _deleteLabel =>
      _isAr ? '\u062d\u0630\u0641' : _isEn ? 'Delete' : 'Löschen';

  @override
  void initState() {
    super.initState();
    _bm = Map<String, List<int>>.from(
      widget.bookmarks.map((k, v) => MapEntry(k, List<int>.from(v))),
    );
  }

  @override
  void dispose() {
    _newCatController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final name = _newCatController.text.trim();
    if (name.isEmpty || _bm.containsKey(name)) return;
    setState(() {
      _bm[name] = [];
      _newCatController.clear();
    });
    widget.onBookmarksUpdated(_bm);
  }

  void _removePage(String cat, int page) {
    setState(() {
      _bm[cat]?.remove(page);
    });
    widget.onBookmarksUpdated(_bm);
  }

  void _removeCategory(String cat) {
    setState(() => _bm.remove(cat));
    widget.onBookmarksUpdated(_bm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: Text(_pageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _newCatHint,
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: Text(_addLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: widget.themeColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _bm.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _emptyHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: _bm.entries.map((entry) {
                final cat = entry.key;
                final pages = entry.value;
                return Card(
                  color: const Color(0xFF1e1e1e),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                        color: widget.themeColor.withOpacity(0.35), width: 1.5),
                  ),
                  child: ExpansionTile(
                    iconColor: widget.themeColor,
                    collapsedIconColor: widget.themeColor,
                    leading: Icon(Icons.folder_open, color: widget.themeColor),
                    title: Text(
                      cat,
                      style: TextStyle(
                          color: widget.themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    subtitle: Text(
                      '${pages.length} ${_isAr ? "\u0635\u0641\u062d\u0629" : _isEn ? "pages" : "Seiten"}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                          tooltip: _deleteLabel,
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: const Color(0xFF1a1a1a),
                              title: Text(
                                _isAr
                                    ? '\u062d\u0630\u0641 "\$cat"?'
                                    : _isEn
                                        ? 'Delete "$cat"?'
                                        : '"$cat" löschen?',
                                style: const TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                      _isAr
                                          ? '\u0625\u0644\u063a\u0627\u0621'
                                          : _isEn
                                              ? 'Cancel'
                                              : 'Abbrechen',
                                      style: const TextStyle(
                                          color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _removeCategory(cat);
                                  },
                                  child: Text(_deleteLabel,
                                      style: const TextStyle(
                                          color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: pages.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _isAr
                                    ? '\u0644\u0627 \u062a\u0648\u062c\u062f \u0635\u0641\u062d\u0627\u062a \u0645\u062d\u0641\u0648\u0638\u0629'
                                    : _isEn
                                        ? 'No pages saved here'
                                        : 'Keine Seiten gespeichert',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 13),
                              ),
                            )
                          ]
                        : pages
                            .map((page) => ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 2),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: widget.themeColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              widget.themeColor.withOpacity(0.4)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$page',
                                        style: TextStyle(
                                            color: widget.themeColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    _isAr
                                        ? '\u0635\u0641\u062d\u0629 $page'
                                        : _isEn
                                            ? 'Page $page'
                                            : 'Seite $page',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            widget.onNavigateToPage(page),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: widget.themeColor,
                                          foregroundColor: Colors.black,
                                          minimumSize: const Size(60, 34),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Text(_goToPageLabel,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white38, size: 18),
                                        onPressed: () =>
                                            _removePage(cat, page),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

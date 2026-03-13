import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  const MushafReaderPage({
    super.key,
    this.themeColor = Colors.teal,
    this.onShowSurahList,
  });

  @override
  State<MushafReaderPage> createState() => _MushafReaderPageState();
}

class _MushafReaderPageState extends State<MushafReaderPage> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _showUI = true;
  static const int totalAssetPages = 604;
  static const int skippedAssetPages = 2;
  static const int totalPages = totalAssetPages - skippedAssetPages;
  static const int pageNumberingVersion = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _convertToPhysicalIndex(1));
    _initializeMushaf();
  }

  /// Initialisiere Mushaf sofort ohne separate Warteansicht.
  void _initializeMushaf() {
    _loadSavedPage();
  }
  
  Future<void> _loadSavedPage() async {
    int savedPage = 1;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawPage = prefs.getInt('mushaf_last_page');
      final version = prefs.getInt('mushaf_page_numbering_version') ?? 1;

      if (rawPage != null) {
        savedPage = version >= pageNumberingVersion
            ? rawPage.clamp(1, totalPages)
            : (rawPage - 1).clamp(1, totalPages);
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
    return totalPages - visiblePage;
  }

  /// Konvertiere physischen Index zu sichtbarer Seite.
  int _convertToLogicalPage(int physicalIndex) {
    return totalPages - physicalIndex;
  }
  
  /// Preload aktuelle Seite + 2 Nachbarn für smooth scrolling
  void _preloadPages(int visiblePage) {
    final pagesToPreload = [
      visiblePage - 1,
      visiblePage,
      visiblePage + 1,
    ];
    
    for (final page in pagesToPreload) {
      if (page >= 1 && page <= totalPages) {
        final pageNum = _formatPageNumber(page);
        final imagePath = 'assets/mushaf_pages/$pageNum.png';
        final mediaQuery = MediaQuery.of(context);
        final targetWidth =
            (mediaQuery.size.width * mediaQuery.devicePixelRatio)
                .clamp(900.0, 1800.0)
                .round();
        // Preload in Flutter's Image Cache with resized decode for faster startup.
        precacheImage(
          ResizeImage(AssetImage(imagePath), width: targetWidth),
          context,
        );
      }
    }
  }
  
  /// Formatiere Seitenzahl für URL
  String _formatPageNumber(int visiblePage) {
    final assetPageNumber = visiblePage + skippedAssetPages;
    return assetPageNumber.toString().padLeft(3, '0');
  }
  
  /// Speichere aktuelle Seite persistent
  Future<void> _savePage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mushaf_last_page', _currentPage);
      await prefs.setInt('mushaf_page_numbering_version', pageNumberingVersion);
    } catch (e) {
      debugPrint('Fehler beim Speichern: $e');
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showUI ? _buildAppBar() : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showUI = !_showUI;
          });
        },
        child: _buildPageView(),
      ),
      bottomNavigationBar: _showUI ? _buildBottomBar() : null,
    );
  }
  
  /// AppBar mit Seitenzahl und Aktionen
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: widget.themeColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Kein Zurück-Button
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, size: 24),
          const SizedBox(width: 10),
          Text(
            'مصحف - صفحة $_currentPage',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Surah-Liste Button (in Ecke)
        if (widget.onShowSurahList != null)
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Surah Liste',
            onPressed: widget.onShowSurahList,
          ),
        // Springe zu Seite
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Zur Seite springen',
          onPressed: _showPageJumpDialog,
        ),
        // Info-Button entfernt
      ],
    );
  }
  
  /// Haupt-PageView mit RTL und Zoom
  Widget _buildPageView() {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int physicalIndex) {
        final visiblePage = _convertToLogicalPage(physicalIndex);
        final pageNum = _formatPageNumber(visiblePage);
        final imagePath = 'assets/mushaf_pages/$pageNum.png';
        final mediaQuery = MediaQuery.of(context);
        final targetWidth =
            (mediaQuery.size.width * mediaQuery.devicePixelRatio)
                .clamp(900.0, 1800.0)
                .round();
        
        return PhotoViewGalleryPageOptions(
          // Decode at device-appropriate width for better speed/memory.
          imageProvider: ResizeImage(AssetImage(imagePath), width: targetWidth),
          
          // Initial: Größer als Standard
          initialScale: PhotoViewComputedScale.contained * 1.2,
          
          // Min: 80% von contained (etwas rauszoomen möglich)
          minScale: PhotoViewComputedScale.contained * 0.8,
          
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
                    'Seite $visiblePage konnte nicht geladen werden',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      },
      
      itemCount: totalPages,
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
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Vorherige Seite (nach rechts in RTL)
            _buildNavButton(
              icon: Icons.arrow_forward,
              label: 'السابق',
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
                '$_currentPage / $totalPages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColor,
                ),
              ),
            ),
            
            // Nächste Seite (nach links in RTL)
            _buildNavButton(
              icon: Icons.arrow_back,
              label: 'التالي',
              onPressed: _currentPage < totalPages ? _goToNextPage : null,
            ),
          ],
        ),
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
    if (_currentPage < totalPages) {
      final nextLogicalPage = (_currentPage + 1).clamp(1, totalPages);
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
      final prevLogicalPage = (_currentPage - 1).clamp(1, totalPages);
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
        title: const Text('إلى صفحة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Seitenzahl (1-$totalPages)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.tag),
          ),
          onSubmitted: (_) => _jumpToPage(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _jumpToPage(controller.text),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
  }
  
  /// Springe zu eingegebener Seite
  void _jumpToPage(String input) {
    final pageNumber = int.tryParse(input);
    if (pageNumber == null || pageNumber < 1 || pageNumber > totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte Zahl zwischen 1 und $totalPages eingeben'),
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

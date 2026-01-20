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
  int _currentPage = 0;
  bool _isLoading = true;
  bool _showUI = true; // UI sichtbar/versteckt
  
  /// Madani Mushaf hat 604 Seiten
  static const int totalPages = 604;
  
  @override
  void initState() {
    super.initState();
    _initializeMushaf();
  }
  
  /// Initialisiere Mushaf: Lade letzte Seite und setup PageController
  Future<void> _initializeMushaf() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPage = prefs.getInt('mushaf_last_page') ?? 2; // Start ab Seite 3 (Index 2)
      
      // Validiere gespeicherte Seite
      final validPage = savedPage.clamp(2, totalPages - 1); // Minimum ist Seite 3
      
      setState(() {
        _currentPage = validPage;
        _isLoading = false;
      });
      
      // RTL: Physische Seite = totalPages - 1 - logische Seite
      // Beispiel: Seite 0 (erste Seite) -> physischer Index 603 (ganz rechts)
      final physicalIndex = _convertToPhysicalIndex(_currentPage);
      
      _pageController = PageController(initialPage: physicalIndex);
      
      // Preload aktuelle Seite und Nachbarn
      _preloadPages(_currentPage);
      
    } catch (e) {
      debugPrint('Fehler beim Initialisieren: $e');
      setState(() {
        _isLoading = false;
        _currentPage = 0;
      });
      _pageController = PageController(initialPage: totalPages - 1);
    }
  }
  
  /// Konvertiere logische Seite (0-603) zu physischem Index für RTL
  int _convertToPhysicalIndex(int logicalPage) {
    return totalPages - 1 - logicalPage;
  }
  
  /// Konvertiere physischen Index zu logischer Seite
  int _convertToLogicalPage(int physicalIndex) {
    return totalPages - 1 - physicalIndex;
  }
  
  /// Preload aktuelle Seite + 2 Nachbarn für smooth scrolling
  void _preloadPages(int logicalPage) {
    final pagesToPreload = [
      logicalPage - 1, // vorherige
      logicalPage,     // aktuelle
      logicalPage + 1, // nächste
    ];
    
    for (final page in pagesToPreload) {
      if (page >= 0 && page < totalPages) {
        final pageNum = _formatPageNumber(page);
        final imageUrl = 'https://tanzil.net/pub/img/pages/hafs/$pageNum.png';
        // Preload in Flutter's Image Cache
        precacheImage(NetworkImage(imageUrl), context);
      }
    }
  }
  
  /// Formatiere Seitenzahl für URL
  String _formatPageNumber(int logicalPage) {
    final pageNumber = logicalPage + 1; // 1-basiert
    return pageNumber.toString().padLeft(3, '0');
  }
  
  /// Speichere aktuelle Seite persistent
  Future<void> _savePage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mushaf_last_page', _currentPage);
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: widget.themeColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'مصحف يُفتح...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mushaf wird geladen...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
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
            'مصحف - صفحة ${_currentPage + 1}',
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
        // Info
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Info',
          onPressed: _showInfoDialog,
        ),
      ],
    );
  }
  
  /// Haupt-PageView mit RTL und Zoom
  Widget _buildPageView() {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int physicalIndex) {
        final logicalPage = _convertToLogicalPage(physicalIndex);
        final pageNum = _formatPageNumber(logicalPage);
        
        return PhotoViewGalleryPageOptions(
          // Lade von lokalem Asset (falls vorhanden) sonst Placeholder
          imageProvider: AssetImage(
            'assets/mushaf_pages/$pageNum.png',
          ),
          
          // Initial: Fit to screen
          initialScale: PhotoViewComputedScale.contained,
          
          // Min: 80% von contained (etwas rauszoomen möglich)
          minScale: PhotoViewComputedScale.contained * 0.8,
          
          // Max: 3x zoom
          maxScale: PhotoViewComputedScale.covered * 3.0,
          
          // Hero animation für smooth transitions
          heroAttributes: PhotoViewHeroAttributes(
            tag: 'mushaf_page_$logicalPage',
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
                    'Seite ${logicalPage + 1} konnte nicht geladen werden',
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
        if (event == null) {
          return Center(
            child: CircularProgressIndicator(color: widget.themeColor),
          );
        }
        
        final progress = event.cumulativeBytesLoaded / 
                        (event.expectedTotalBytes ?? 1);
        
        return Center(
          child: CircularProgressIndicator(
            value: progress,
            color: widget.themeColor,
          ),
        );
      },
      
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
      
      pageController: _pageController,
      
      // Callback wenn Seite gewechselt wird
      onPageChanged: (physicalIndex) {
        final logicalPage = _convertToLogicalPage(physicalIndex);
        
        setState(() {
          _currentPage = logicalPage;
        });
        
        // Speichere neue Seite
        _savePage();
        
        // Preload Nachbarseiten
        _preloadPages(logicalPage);
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
              onPressed: _currentPage > 0 ? _goToPreviousPage : null,
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
                '${_currentPage + 1} / $totalPages',
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
              onPressed: _currentPage < totalPages - 1 ? _goToNextPage : null,
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
    if (_currentPage < totalPages - 1) {
      final nextLogicalPage = _currentPage + 1;
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
    if (_currentPage > 0) {
      final prevLogicalPage = _currentPage - 1;
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
    final controller = TextEditingController(text: '${_currentPage + 1}');
    
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
    
    final logicalPage = pageNumber - 1;
    final physicalIndex = _convertToPhysicalIndex(logicalPage);
    
    _pageController.jumpToPage(physicalIndex);
    Navigator.pop(context);
  }
  
  /// Info Dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مصحف - Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('📖', 'Madani Mushaf'),
            _buildInfoRow('📄', '$totalPages Seiten'),
            _buildInfoRow('👆', 'Wischen zum Blättern'),
            _buildInfoRow('🔍', 'Pinch/Doppeltipp zum Zoomen'),
            _buildInfoRow('💾', 'Seite wird automatisch gespeichert'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

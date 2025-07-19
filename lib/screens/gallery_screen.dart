import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'dart:typed_data';

import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/custom_widgets.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../widgets/gallery_item_widget.dart';
import '../widgets/gallery_filter_bar.dart';
import 'preview_screen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  final AdService _adService = AdService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<GalleryItem> _allItems = [];
  List<GalleryItem> _filteredItems = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final Set<String> _selectedItems = {};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGalleryItems();
    _loadBannerAd();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.fadeInDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );
  }

  Future<void> _loadGalleryItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _storageService.getGalleryItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });

      _animationController.forward();
      _applyFilters();
    } catch (e) {
      print('ギャラリーアイテム読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBannerAd() async {
    _bannerAd = _adService.createBannerAd();
    await _bannerAd!.load();

    setState(() {
      _isBannerAdReady = true;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        // タイプフィルター
        bool matchesType = true;
        if (_selectedFilter == 'images') {
          matchesType = item.isImage;
        } else if (_selectedFilter == 'gifs') {
          matchesType = item.isGif;
        }

        // 検索フィルター
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          matchesSearch = item.fileName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
        }

        return matchesType && matchesSearch;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
    HapticFeedback.lightImpact();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _toggleItemSelection(String itemPath) {
    setState(() {
      if (_selectedItems.contains(itemPath)) {
        _selectedItems.remove(itemPath);
      } else {
        _selectedItems.add(itemPath);
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _deleteSelectedItems() async {
    final localizations = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteConfirmation),
        content: Text('${_selectedItems.length}個のアイテムを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.delete),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final itemPath in _selectedItems) {
        await _storageService.deleteGalleryItem(itemPath);
      }

      _selectedItems.clear();
      _toggleSelectionMode();
      await _loadGalleryItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('アイテムを削除しました'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _shareSelectedItems() async {
    try {
      final filePaths = _selectedItems.toList();

      if (filePaths.isNotEmpty) {
        await Share.shareFiles(filePaths, text: '#DotAnimeCam で作成したドット絵です！');

        // インタースティシャル広告を表示
        if (await _adService.shouldShowAd()) {
          await _adService.showInterstitialAd();
        }
      }
    } catch (e) {
      print('シェアエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('シェアに失敗しました'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _openItem(GalleryItem item) async {
    try {
      final imageBytes = await item.getBytes();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            imageBytes: imageBytes,
            onRetake: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } catch (e) {
      print('アイテム表示エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の表示に失敗しました'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _refreshGallery() async {
    await _loadGalleryItems();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(localizations),
      body: Column(
        children: [
          // 検索バー
          _buildSearchBar(localizations),

          // フィルターバー
          GalleryFilterBar(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
            itemCounts: {
              'all': _allItems.length,
              'images': _allItems.where((item) => item.isImage).length,
              'gifs': _allItems.where((item) => item.isGif).length,
            },
          ),

          // メインコンテンツ
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _filteredItems.isEmpty
                ? _buildEmptyView(localizations)
                : _buildGalleryGrid(),
          ),

          // バナー広告
          if (_isBannerAdReady && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations localizations) {
    return AppBar(
      title: Text(
        _isSelectionMode
            ? '${_selectedItems.length}個選択中'
            : localizations.galleryTitle,
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _selectedItems.isNotEmpty ? _shareSelectedItems : null,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedItems.isNotEmpty ? _deleteSelectedItems : null,
          ),
        ] else ...[
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: _filteredItems.isNotEmpty ? _toggleSelectionMode : null,
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshGallery),
        ],
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '検索...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: AppColors.background,
        ),
        onChanged: (value) {
          // _onSearchChanged は既に addListener で設定済み
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            AppLocalizations.of(context)!.loading,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations localizations) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: EmptyState(
          title: localizations.emptyGallery,
          subtitle: localizations.emptyGallerySubtitle,
          icon: Icons.photo_library_outlined,
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshGallery,
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.paddingMedium,
              mainAxisSpacing: AppDimensions.paddingMedium,
              childAspectRatio: 1.0,
            ),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = _selectedItems.contains(item.filePath);

              return GalleryItemWidget(
                key: Key(item.filePath),
                item: item,
                isSelected: isSelected,
                isSelectionMode: _isSelectionMode,
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleItemSelection(item.filePath);
                  } else {
                    _openItem(item);
                  }
                },
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                  }
                  _toggleItemSelection(item.filePath);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

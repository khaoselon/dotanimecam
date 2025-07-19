import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/custom_widgets.dart';
import '../services/dot_art_service.dart';
import '../services/gif_service.dart';
import '../services/storage_service.dart';
import '../widgets/comparison_card.dart';

class PreviewScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback onRetake;

  const PreviewScreen({
    Key? key,
    required this.imageBytes,
    required this.onRetake,
  }) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final DotArtService _dotArtService = DotArtService();
  final GifService _gifService = GifService();
  final StorageService _storageService = StorageService();

  Uint8List? _dotArtBytes;
  bool _isProcessing = false;
  bool _isFlipped = false;
  bool _isSaving = false;
  bool _isSharing = false;
  String _processingMessage = '';

  // 設定値
  int _dotSize = AppConstants.defaultDotSize;
  int _colorPalette = AppConstants.defaultColorPalette;
  DotStyle _dotStyle = DotStyle.square;
  ComparisonLayout _comparisonLayout = ComparisonLayout.sideBySide;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
    _generateDotArt();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: AppConstants.cardFlipDuration,
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: AppConstants.fadeInDuration,
      vsync: this,
    );

    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: AppAnimations.cardFlipCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _loadingAnimationController,
            curve: Curves.easeOutBack,
          ),
        );

    _loadingAnimationController.forward();
  }

  Future<void> _loadSettings() async {
    // SharedPreferencesから設定を読み込み
    // 実装は省略（設定画面作成時に詳細実装）
  }

  Future<void> _generateDotArt() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = AppLocalizations.of(context)!.processingDotArt;
    });

    try {
      final dotArtBytes = await _dotArtService.convertToDotArt(
        widget.imageBytes,
        dotSize: _dotSize,
        colorPalette: _colorPalette,
        dotStyle: _dotStyle,
      );

      setState(() {
        _dotArtBytes = dotArtBytes;
        _isProcessing = false;
      });

      // 成功時の触覚フィードバック
      HapticFeedback.lightImpact();
    } catch (e) {
      print('ドット絵変換エラー: $e');
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar(AppLocalizations.of(context)!.imageProcessingFailed);
    }
  }

  void _flipCard() {
    if (_isProcessing) return;

    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _cardAnimationController.forward();
    } else {
      _cardAnimationController.reverse();
    }

    // 触覚フィードバック
    HapticFeedback.mediumImpact();
  }

  Future<void> _saveImage({bool saveComparison = false}) async {
    if (_dotArtBytes == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;
      String? filePath;

      if (saveComparison) {
        // 比較GIF作成
        setState(() {
          _processingMessage = localizations.gifCreated;
        });

        final gifBytes = await _gifService.createComparisonGif(
          widget.imageBytes,
          _dotArtBytes!,
          layout: _comparisonLayout,
        );

        filePath = await _storageService.saveGif(gifBytes);
      } else {
        // 単体画像保存
        final imageToSave = _isFlipped ? _dotArtBytes! : widget.imageBytes;
        filePath = await _storageService.saveImage(imageToSave);
      }

      if (filePath != null) {
        // ギャラリーに保存
        await ImageGallerySaver.saveFile(filePath);
        _showSuccessSnackBar(localizations.savedSuccessfully);
      }
    } catch (e) {
      print('保存エラー: $e');
      _showErrorSnackBar(AppLocalizations.of(context)!.saveFailed);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareImage({bool shareComparison = false}) async {
    if (_dotArtBytes == null) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;
      String? filePath;

      if (shareComparison) {
        // 比較GIF作成
        final gifBytes = await _gifService.createComparisonGif(
          widget.imageBytes,
          _dotArtBytes!,
          layout: _comparisonLayout,
        );

        filePath = await _storageService.saveTemporaryGif(gifBytes);
      } else {
        // 単体画像
        final imageToShare = _isFlipped ? _dotArtBytes! : widget.imageBytes;
        filePath = await _storageService.saveTemporaryImage(imageToShare);
      }

      if (filePath != null) {
        await Share.shareFiles([filePath], text: '#DotAnimeCam で作成したドット絵です！');
      }
    } catch (e) {
      print('シェアエラー: $e');
      _showErrorSnackBar(AppLocalizations.of(context)!.shareFailed);
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSaveOptions() {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.exportOptions, style: AppTextStyles.heading3),
            SizedBox(height: AppDimensions.paddingLarge),
            _buildOptionTile(
              icon: Icons.image,
              title: localizations.singleImage,
              subtitle: _isFlipped
                  ? localizations.dotArt
                  : localizations.original,
              onTap: () {
                Navigator.pop(context);
                _saveImage(saveComparison: false);
              },
            ),
            _buildOptionTile(
              icon: Icons.compare,
              title: localizations.bothImages,
              subtitle: '${localizations.original} & ${localizations.dotArt}',
              onTap: () {
                Navigator.pop(context);
                _saveImage(saveComparison: false);
                _saveImage(saveComparison: false);
              },
            ),
            _buildOptionTile(
              icon: Icons.gif,
              title: localizations.comparisonVideo,
              subtitle: 'GIF アニメーション',
              onTap: () {
                Navigator.pop(context);
                _saveImage(saveComparison: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions() {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.share, style: AppTextStyles.heading3),
            SizedBox(height: AppDimensions.paddingLarge),
            _buildOptionTile(
              icon: Icons.image,
              title: localizations.singleImage,
              subtitle: _isFlipped
                  ? localizations.dotArt
                  : localizations.original,
              onTap: () {
                Navigator.pop(context);
                _shareImage(shareComparison: false);
              },
            ),
            _buildOptionTile(
              icon: Icons.gif,
              title: localizations.comparisonVideo,
              subtitle: 'GIF アニメーション',
              onTap: () {
                Navigator.pop(context);
                _shareImage(shareComparison: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconSizeMedium,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.dotBackground,
      appBar: AppBar(
        backgroundColor: AppColors.dotBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.surface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations.preview,
          style: AppTextStyles.heading3.copyWith(color: AppColors.surface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.surface),
            onPressed: _generateDotArt,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // メインコンテンツ
            Expanded(
              child: _isProcessing
                  ? _buildProcessingView(localizations)
                  : _buildComparisonView(localizations),
            ),

            // アクションボタン
            ActionButtonRow(
              onRetake: widget.onRetake,
              onSave: _showSaveOptions,
              onShare: _showShareOptions,
              onCompare: _flipCard,
              isProcessing: _isProcessing,
              isSaving: _isSaving,
              isSharing: _isSharing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView(AppLocalizations localizations) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 元画像プレビュー
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
                ),
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // ローディング
              CustomLoading(
                message: _processingMessage,
                color: AppColors.surface,
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              // 進捗メッセージ
              Text(
                localizations.processingDotArt,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.surface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonView(AppLocalizations localizations) {
    if (_dotArtBytes == null) {
      return Center(
        child: ErrorDisplay(
          message: localizations.imageProcessingFailed,
          onRetry: _generateDotArt,
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              // 比較カード
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: ComparisonCard(
                    originalImage: widget.imageBytes,
                    dotArtImage: _dotArtBytes!,
                    animation: _cardFlipAnimation,
                    isFlipped: _isFlipped,
                    layout: _comparisonLayout,
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              // 表示状態インジケーター
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.surface.withOpacity(0.7),
                    size: AppDimensions.iconSizeSmall,
                  ),
                  SizedBox(width: AppDimensions.paddingSmall / 2),
                  Text(
                    _isFlipped ? localizations.dotArt : localizations.original,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.surface.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingSmall),
                  Text(
                    localizations.compare,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.surface.withOpacity(0.7),
                    ),
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

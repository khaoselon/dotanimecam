import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'dart:typed_data';

import '../main.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/custom_widgets.dart';
import '../services/camera_service.dart';
import '../services/dot_art_service.dart';
import '../services/ad_service.dart';
import 'preview_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;
  int _currentPageIndex = 0;
  int _photoCount = 0;

  FlashMode _flashMode = FlashMode.auto;
  ResolutionPreset _resolutionPreset = ResolutionPreset.high;

  final PageController _pageController = PageController();
  final CameraService _cameraService = CameraService();
  final DotArtService _dotArtService = DotArtService();
  final AdService _adService = AdService();

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializeAnimations();
    _loadBannerAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _animationController.dispose();
    _pageController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.fadeInDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      if (cameras.isEmpty) {
        setState(() {
          _isInitialized = false;
        });
        return;
      }

      final camera = cameras[_selectedCameraIndex];
      _cameraController = CameraController(
        camera,
        _resolutionPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _animationController.forward();
      }
    } catch (e) {
      print('カメラ初期化エラー: $e');
      setState(() {
        _isInitialized = false;
      });
    }
  }

  Future<void> _loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('バナー広告が読み込まれました');
        },
        onAdFailedToLoad: (ad, error) {
          print('バナー広告の読み込みに失敗しました: $error');
          ad.dispose();
        },
      ),
    );

    await _bannerAd!.load();
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _isCapturing || _cameraController == null) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // 触覚フィードバック
      HapticFeedback.mediumImpact();

      // シャッター音（iOSで自動再生）
      if (Platform.isIOS) {
        SystemSound.play(SystemSoundType.click);
      }

      // 写真撮影
      final image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      // インタースティシャル広告表示チェック
      _photoCount++;
      if (_photoCount % AppConstants.interstitialAdInterval == 0) {
        await _adService.showInterstitialAd();
      }

      // プレビュー画面に遷移
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            imageBytes: imageBytes,
            onRetake: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } catch (e) {
      print('写真撮影エラー: $e');
      _showErrorSnackBar('写真撮影に失敗しました');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      setState(() {
        switch (_flashMode) {
          case FlashMode.auto:
            _flashMode = FlashMode.always;
            break;
          case FlashMode.always:
            _flashMode = FlashMode.off;
            break;
          case FlashMode.off:
            _flashMode = FlashMode.auto;
            break;
          default:
            _flashMode = FlashMode.auto;
        }
      });

      await _cameraController!.setFlashMode(_flashMode);
      HapticFeedback.lightImpact();
    } catch (e) {
      print('フラッシュ切り替えエラー: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length <= 1) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    });

    await _cameraController?.dispose();
    await _initializeCamera();

    HapticFeedback.lightImpact();
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

  void _navigateToPage(int index) {
    setState(() {
      _currentPageIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: AppConstants.slideInDuration,
      curve: Curves.easeInOut,
    );

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.dotBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ページビュー
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  _buildCameraPage(localizations),
                  GalleryScreen(),
                  SettingsScreen(),
                ],
              ),
            ),

            // バナー広告
            if (_bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),

            // ボトムナビゲーション
            _buildBottomNavigation(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPage(AppLocalizations localizations) {
    if (!_isInitialized) {
      return _buildCameraError(localizations);
    }

    return Column(
      children: [
        // カメラヘッダー
        _buildCameraHeader(localizations),

        // カメラプレビュー
        Expanded(
          child: Stack(
            children: [
              // カメラプレビュー
              _buildCameraPreview(),

              // オーバーレイ
              if (_isCapturing || _isProcessing)
                _buildProcessingOverlay(localizations),
            ],
          ),
        ),

        // カメラコントロール
        _buildCameraControls(localizations),
      ],
    );
  }

  Widget _buildCameraError(AppLocalizations localizations) {
    return ErrorDisplay(
      message: localizations.cameraInitializationFailed,
      onRetry: _initializeCamera,
      icon: Icons.camera_alt_outlined,
    );
  }

  Widget _buildCameraHeader(AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // アプリタイトル
          Text(
            localizations.appName,
            style: AppTextStyles.heading3.copyWith(color: AppColors.surface),
          ),

          // クイック設定ボタン
          Row(
            children: [
              _buildQuickButton(
                icon: _getFlashIcon(),
                onPressed: _toggleFlash,
                isActive: _flashMode != FlashMode.off,
              ),
              SizedBox(width: AppDimensions.paddingSmall),
              if (cameras.length > 1)
                _buildQuickButton(
                  icon: Icons.flip_camera_ios,
                  onPressed: _switchCamera,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppConstants.fadeInDuration,
        width: AppDimensions.quickButtonSize,
        height: AppDimensions.quickButtonSize,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.8)
              : AppColors.surface.withOpacity(0.2),
          borderRadius: BorderRadius.circular(
            AppDimensions.quickButtonSize / 2,
          ),
          border: Border.all(
            color: AppColors.surface.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.surface,
          size: AppDimensions.iconSizeMedium,
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay(AppLocalizations localizations) {
    return Container(
      color: AppColors.dotBackground.withOpacity(0.8),
      child: Center(
        child: CustomLoading(
          message: _isProcessing
              ? localizations.processingDotArt
              : localizations.processing,
          color: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildCameraControls(AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ギャラリーボタン
          _buildControlButton(
            icon: Icons.photo_library,
            label: localizations.galleryTitle,
            onPressed: () => _navigateToPage(1),
          ),

          // シャッターボタン
          GestureDetector(
            onTap: _takePicture,
            child: AnimatedContainer(
              duration: AppConstants.fadeInDuration,
              width: AppDimensions.shutterButtonSize,
              height: AppDimensions.shutterButtonSize,
              decoration: BoxDecoration(
                color: _isCapturing
                    ? AppColors.surface.withOpacity(0.5)
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isCapturing ? Icons.hourglass_empty : Icons.camera_alt,
                color: AppColors.primary,
                size: AppDimensions.iconSizeLarge,
              ),
            ),
          ),

          // 設定ボタン
          _buildControlButton(
            icon: Icons.settings,
            label: localizations.settingsTitle,
            onPressed: () => _navigateToPage(2),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppDimensions.quickButtonSize,
            height: AppDimensions.quickButtonSize,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                AppDimensions.quickButtonSize / 2,
              ),
              border: Border.all(
                color: AppColors.surface.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.surface,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
          SizedBox(height: AppDimensions.paddingSmall / 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.surface),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(AppLocalizations localizations) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.camera_alt,
            label: localizations.cameraTitle,
            isSelected: _currentPageIndex == 0,
            onTap: () => _navigateToPage(0),
          ),
          _buildNavItem(
            icon: Icons.photo_library,
            label: localizations.galleryTitle,
            isSelected: _currentPageIndex == 1,
            onTap: () => _navigateToPage(1),
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: localizations.settingsTitle,
            isSelected: _currentPageIndex == 2,
            onTap: () => _navigateToPage(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.fadeInDuration,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: AppDimensions.iconSizeMedium,
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }
}

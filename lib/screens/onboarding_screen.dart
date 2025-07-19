import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import '../utils/localization.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({Key? key, required this.onComplete})
    : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;
  bool _isLoading = false;
  bool _permissionsGranted = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'onboarding_title_1',
      subtitle: 'onboarding_subtitle_1',
      iconData: Icons.camera_alt,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'onboarding_title_2',
      subtitle: 'onboarding_subtitle_2',
      iconData: Icons.auto_fix_high,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'onboarding_title_3',
      subtitle: 'onboarding_subtitle_3',
      iconData: Icons.share,
      color: AppColors.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.fadeInDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // カメラ権限
      final cameraStatus = await Permission.camera.request();

      // ストレージ権限
      final storageStatus = await Permission.storage.request();

      // マイク権限（動画撮影用）
      final micStatus = await Permission.microphone.request();

      bool allGranted =
          cameraStatus.isGranted &&
          storageStatus.isGranted &&
          micStatus.isGranted;

      if (!allGranted) {
        // 権限が拒否された場合の処理
        _showPermissionDialog();
        return;
      }

      setState(() {
        _permissionsGranted = true;
      });

      // 少し待ってから完了処理
      await Future.delayed(Duration(milliseconds: 500));
      widget.onComplete();
    } catch (e) {
      print('権限リクエストエラー: $e');
      _showErrorDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        onRetry: _requestPermissions,
        onOpenSettings: () async {
          await openAppSettings();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.errorOccurred),
        content: Text(localizations.permissionDenied),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: Text(localizations.retry),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.slideInDuration,
        curve: Curves.easeInOut,
      );
    } else {
      _requestPermissions();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: AppConstants.slideInDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // スキップボタン
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Align(
                alignment: Alignment.topRight,
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          localizations.skip,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ),

            // メインコンテンツ
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });

                  // ページ変更時のアニメーション
                  _animationController.reset();
                  _animationController.forward();

                  // 触覚フィードバック
                  HapticFeedback.lightImpact();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPageContent(page, localizations);
                },
              ),
            ),

            // インジケーターとボタン
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                children: [
                  // ページインジケーター
                  AnimatedPageIndicator(
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                  ),

                  SizedBox(height: AppDimensions.paddingLarge),

                  // ボタン
                  Row(
                    children: [
                      // 戻るボタン
                      if (_currentPage > 0)
                        Expanded(
                          child: CustomButton(
                            text: localizations.cancel,
                            onPressed: () {
                              _pageController.previousPage(
                                duration: AppConstants.slideInDuration,
                                curve: Curves.easeInOut,
                              );
                            },
                            backgroundColor: AppColors.surface,
                            textColor: AppColors.textSecondary,
                            borderColor: AppColors.divider,
                          ),
                        ),

                      if (_currentPage > 0)
                        SizedBox(width: AppDimensions.paddingMedium),

                      // 次へ/開始ボタン
                      Expanded(
                        flex: _currentPage > 0 ? 1 : 1,
                        child: CustomButton(
                          text: _currentPage == _pages.length - 1
                              ? localizations.start
                              : localizations.next,
                          onPressed: _isLoading ? null : _nextPage,
                          isLoading: _isLoading,
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(
    OnboardingPage page,
    AppLocalizations localizations,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アイコン
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.iconData, size: 60, color: page.color),
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // タイトル
              Text(
                _getLocalizedText(page.title, localizations),
                style: AppTextStyles.heading1.copyWith(color: page.color),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingMedium),

              // サブタイトル
              Text(
                _getLocalizedText(page.subtitle, localizations),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // チュートリアル用のGIF画像（実装時に追加）
              _buildTutorialAnimation(page),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialAnimation(OnboardingPage page) {
    // 実際の実装では、GIF画像やLottieアニメーションを表示
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          page.iconData,
          size: 80,
          color: page.color.withOpacity(0.3),
        ),
      ),
    );
  }

  String _getLocalizedText(String key, AppLocalizations localizations) {
    switch (key) {
      case 'onboarding_title_1':
        return localizations.onboardingTitle1;
      case 'onboarding_subtitle_1':
        return localizations.onboardingSubtitle1;
      case 'onboarding_title_2':
        return localizations.onboardingTitle2;
      case 'onboarding_subtitle_2':
        return localizations.onboardingSubtitle2;
      case 'onboarding_title_3':
        return localizations.onboardingTitle3;
      case 'onboarding_subtitle_3':
        return localizations.onboardingSubtitle3;
      default:
        return key;
    }
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.color,
  });
}

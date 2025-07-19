import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6B73FF);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // ドット絵関連カラー
  static const Color dotBackground = Color(0xFF2D2D2D);
  static const Color dotPreview = Color(0xFF1E1E1E);
  static const Color pixelBorder = Color(0xFF424242);
}

class AppConstants {
  // 広告ID (テスト用)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // ドット絵変換設定
  static const int defaultDotSize = 8;
  static const int minDotSize = 4;
  static const int maxDotSize = 16;
  static const int defaultColorPalette = 16;
  static const int minColorPalette = 8;
  static const int maxColorPalette = 64;

  // アプリ設定
  static const int maxGalleryItems = 100;
  static const int interstitialAdInterval = 5; // 5回撮影ごとに表示
  static const int jpegQuality = 90;
  static const int gifFrameDelay = 100; // ミリ秒

  // アニメーション設定
  static const Duration cardFlipDuration = Duration(milliseconds: 600);
  static const Duration fadeInDuration = Duration(milliseconds: 300);
  static const Duration slideInDuration = Duration(milliseconds: 400);

  // ファイル関連
  static const String galleryDirectoryName = 'DotAnimeCam';
  static const String originalImagePrefix = 'original_';
  static const String dotImagePrefix = 'dot_';
  static const String comparisonGifPrefix = 'comparison_';
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;

  static const double cardElevation = 2.0;
  static const double modalElevation = 8.0;

  // カメラ関連
  static const double cameraPreviewAspectRatio = 4.0 / 3.0;
  static const double comparisonCardAspectRatio = 1.0;
  static const double shutterButtonSize = 80.0;
  static const double quickButtonSize = 56.0;
}

class AppAnimations {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve cardFlipCurve = Curves.easeInOut;

  // カード回転アニメーション用
  static const double cardFlipAngle = 3.14159; // 180度（π）
}

enum DotStyle { square, circle, diamond, pixel }

enum ComparisonLayout { sideBySide, topBottom, overlay }

enum SaveFormat { jpg, png, gif, mp4 }

enum SharePlatform { twitter, instagram, line, airdrop, other }

class AppSettings {
  static const Map<String, String> supportedLanguages = {
    'ja': '日本語',
    'en': 'English',
    'it': 'Italiano',
    'pt': 'Português',
    'es': 'Español',
    'de': 'Deutsch',
    'ko': '한국어',
    'zh': '繁體中文',
  };

  static const Map<String, String> supportedCountries = {
    'ja': 'JP',
    'en': 'US',
    'it': 'IT',
    'pt': 'PT',
    'es': 'ES',
    'de': 'DE',
    'ko': 'KR',
    'zh': 'Hant',
  };
}

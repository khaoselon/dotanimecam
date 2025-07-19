import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'ja': {
      'app_name': 'DotAnimeCam',
      'camera_title': 'カメラ',
      'gallery_title': 'ギャラリー',
      'settings_title': '設定',
      'take_photo': '写真を撮る',
      'retake': '撮り直し',
      'save': '保存',
      'share': 'シェア',
      'compare': '比較',
      'original': 'オリジナル',
      'dot_art': 'ドット絵',
      'processing': '処理中...',
      'processing_dot_art': 'ドット絵を生成中...',
      'saved_successfully': '保存しました',
      'save_failed': '保存に失敗しました',
      'share_failed': 'シェアに失敗しました',
      'camera_permission_required': 'カメラの許可が必要です',
      'storage_permission_required': 'ストレージの許可が必要です',
      'grant_permission': '許可する',
      'settings_open': '設定を開く',
      'dot_size': 'ドットサイズ',
      'color_palette': 'カラーパレット',
      'comparison_layout': '比較レイアウト',
      'side_by_side': '左右比較',
      'top_bottom': '上下比較',
      'overlay': 'オーバーレイ',
      'auto_save': '自動保存',
      'save_location': '保存場所',
      'device_storage': 'デバイス',
      'icloud': 'iCloud',
      'google_photos': 'Google フォト',
      'tutorial': 'チュートリアル',
      'language': '言語',
      'about': 'このアプリについて',
      'version': 'バージョン',
      'privacy_policy': 'プライバシーポリシー',
      'terms_of_service': '利用規約',
      'onboarding_title_1': 'ようこそ！',
      'onboarding_subtitle_1': '写真を撮って、ドット絵に変換しよう',
      'onboarding_title_2': 'カンタン変換',
      'onboarding_subtitle_2': 'ワンタップで美しいドット絵が完成',
      'onboarding_title_3': 'シェアしよう',
      'onboarding_subtitle_3': 'SNSで友達と共有してみよう',
      'next': '次へ',
      'skip': 'スキップ',
      'start': '始める',
      'empty_gallery': 'ギャラリーは空です',
      'empty_gallery_subtitle': '写真を撮って、ドット絵を作成しましょう',
      'delete': '削除',
      'delete_confirmation': '削除しますか？',
      'cancel': 'キャンセル',
      'confirm': '確認',
      'error_occurred': 'エラーが発生しました',
      'retry': 'リトライ',
      'loading': '読み込み中...',
      'no_camera_available': 'カメラが利用できません',
      'flip_camera': 'カメラ切り替え',
      'flash_auto': '自動フラッシュ',
      'flash_on': 'フラッシュON',
      'flash_off': 'フラッシュOFF',
      'quality_high': '高品質',
      'quality_medium': '標準品質',
      'quality_low': '低品質',
      'gif_created': 'GIF作成完了',
      'gif_creation_failed': 'GIF作成に失敗しました',
      'comparison_video': '比較動画',
      'single_image': '単体画像',
      'both_images': '両方の画像',
      'export_options': 'エクスポート形式',
      'style_square': '四角',
      'style_circle': '円',
      'style_diamond': 'ダイヤモンド',
      'style_pixel': 'ピクセル',
      'dot_style': 'ドットスタイル',
      'reset_settings': '設定をリセット',
      'reset_confirmation': '設定をリセットしますか？',
      'rate_app': 'アプリを評価',
      'feedback': 'フィードバック',
      'help': 'ヘルプ',
      'camera_error': 'カメラエラー',
      'camera_initialization_failed': 'カメラの初期化に失敗しました',
      'image_processing_failed': '画像処理に失敗しました',
      'permission_denied': '権限が拒否されました',
      'permission_required_message': 'このアプリを使用するには、以下の権限が必要です：',
      'camera_permission': 'カメラ権限',
      'storage_permission': 'ストレージ権限',
      'microphone_permission': 'マイク権限',
      'tracking_permission': 'トラッキング権限',
      'permission_camera_description': '写真撮影に必要です',
      'permission_storage_description': '画像の保存に必要です',
      'permission_microphone_description': '動画撮影に必要です',
      'permission_tracking_description': '広告の最適化に使用されます',
      'permission_denied_permanent': '権限が永続的に拒否されました。設定から手動で許可してください。',
      'open_settings': '設定を開く',
      'tutorial_step_1': '写真を撮ろう',
      'tutorial_step_2': 'ドット絵に変換',
      'tutorial_step_3': '保存・シェア',
      'tutorial_step_1_description': 'シャッターボタンをタップして写真を撮影します',
      'tutorial_step_2_description': '自動でドット絵に変換されます',
      'tutorial_step_3_description': '保存やシェアして楽しもう',
      'close': '閉じる',
      'preview': 'プレビュー',
      'edit': '編集',
      'filter': 'フィルター',
      'brightness': '明るさ',
      'contrast': 'コントラスト',
      'saturation': '彩度',
      'reset': 'リセット',
      'apply': '適用',
      'undo': '元に戻す',
      'redo': 'やり直し',
    },
    'en': {
      'app_name': 'DotAnimeCam',
      'camera_title': 'Camera',
      'gallery_title': 'Gallery',
      'settings_title': 'Settings',
      'take_photo': 'Take Photo',
      'retake': 'Retake',
      'save': 'Save',
      'share': 'Share',
      'compare': 'Compare',
      'original': 'Original',
      'dot_art': 'Dot Art',
      'processing': 'Processing...',
      'processing_dot_art': 'Generating dot art...',
      'saved_successfully': 'Saved successfully',
      'save_failed': 'Save failed',
      'share_failed': 'Share failed',
      'camera_permission_required': 'Camera permission required',
      'storage_permission_required': 'Storage permission required',
      'grant_permission': 'Grant Permission',
      'settings_open': 'Open Settings',
      'dot_size': 'Dot Size',
      'color_palette': 'Color Palette',
      'comparison_layout': 'Comparison Layout',
      'side_by_side': 'Side by Side',
      'top_bottom': 'Top & Bottom',
      'overlay': 'Overlay',
      'auto_save': 'Auto Save',
      'save_location': 'Save Location',
      'device_storage': 'Device',
      'icloud': 'iCloud',
      'google_photos': 'Google Photos',
      'tutorial': 'Tutorial',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'onboarding_title_1': 'Welcome!',
      'onboarding_subtitle_1': 'Take photos and convert them to dot art',
      'onboarding_title_2': 'Easy Conversion',
      'onboarding_subtitle_2': 'Beautiful dot art with one tap',
      'onboarding_title_3': 'Share It',
      'onboarding_subtitle_3': 'Share with friends on social media',
      'next': 'Next',
      'skip': 'Skip',
      'start': 'Start',
      'empty_gallery': 'Gallery is empty',
      'empty_gallery_subtitle': 'Take photos to create dot art',
      'delete': 'Delete',
      'delete_confirmation': 'Delete this item?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'error_occurred': 'An error occurred',
      'retry': 'Retry',
      'loading': 'Loading...',
      'no_camera_available': 'No camera available',
      'flip_camera': 'Flip Camera',
      'flash_auto': 'Auto Flash',
      'flash_on': 'Flash On',
      'flash_off': 'Flash Off',
      'quality_high': 'High Quality',
      'quality_medium': 'Medium Quality',
      'quality_low': 'Low Quality',
      'gif_created': 'GIF created successfully',
      'gif_creation_failed': 'GIF creation failed',
      'comparison_video': 'Comparison Video',
      'single_image': 'Single Image',
      'both_images': 'Both Images',
      'export_options': 'Export Options',
      'style_square': 'Square',
      'style_circle': 'Circle',
      'style_diamond': 'Diamond',
      'style_pixel': 'Pixel',
      'dot_style': 'Dot Style',
      'reset_settings': 'Reset Settings',
      'reset_confirmation': 'Reset all settings?',
      'rate_app': 'Rate App',
      'feedback': 'Feedback',
      'help': 'Help',
      'camera_error': 'Camera Error',
      'camera_initialization_failed': 'Camera initialization failed',
      'image_processing_failed': 'Image processing failed',
      'permission_denied': 'Permission denied',
      'permission_required_message':
          'This app requires the following permissions:',
      'camera_permission': 'Camera Permission',
      'storage_permission': 'Storage Permission',
      'microphone_permission': 'Microphone Permission',
      'tracking_permission': 'Tracking Permission',
      'permission_camera_description': 'Required for taking photos',
      'permission_storage_description': 'Required for saving images',
      'permission_microphone_description': 'Required for video recording',
      'permission_tracking_description': 'Used for ad optimization',
      'permission_denied_permanent':
          'Permission permanently denied. Please grant manually from settings.',
      'open_settings': 'Open Settings',
      'tutorial_step_1': 'Take a Photo',
      'tutorial_step_2': 'Convert to Dot Art',
      'tutorial_step_3': 'Save & Share',
      'tutorial_step_1_description': 'Tap the shutter button to take a photo',
      'tutorial_step_2_description': 'Automatically converts to dot art',
      'tutorial_step_3_description': 'Save and share to enjoy',
      'close': 'Close',
      'preview': 'Preview',
      'edit': 'Edit',
      'filter': 'Filter',
      'brightness': 'Brightness',
      'contrast': 'Contrast',
      'saturation': 'Saturation',
      'reset': 'Reset',
      'apply': 'Apply',
      'undo': 'Undo',
      'redo': 'Redo',
    },
    // 他の言語も同様に追加（簡略化のため一部のみ表示）
    'it': {
      'app_name': 'DotAnimeCam',
      'camera_title': 'Fotocamera',
      'gallery_title': 'Galleria',
      'settings_title': 'Impostazioni',
      'take_photo': 'Scatta Foto',
      'retake': 'Ripeti',
      'save': 'Salva',
      'share': 'Condividi',
      'compare': 'Confronta',
      'original': 'Originale',
      'dot_art': 'Pixel Art',
      'processing': 'Elaborazione...',
      'processing_dot_art': 'Generazione pixel art...',
      // 他の翻訳も同様に...
    },
    'pt': {
      'app_name': 'DotAnimeCam',
      'camera_title': 'Câmera',
      'gallery_title': 'Galeria',
      'settings_title': 'Configurações',
      'take_photo': 'Tirar Foto',
      'retake': 'Refazer',
      'save': 'Salvar',
      'share': 'Compartilhar',
      'compare': 'Comparar',
      'original': 'Original',
      'dot_art': 'Arte Pixel',
      'processing': 'Processando...',
      'processing_dot_art': 'Gerando arte pixel...',
      // 他の翻訳も同様に...
    },
    'es': {
      'app_name': 'DotAnimeCam',
      'camera_title': 'Cámara',
      'gallery_title': 'Galería',
      'settings_title': 'Ajustes',
      'take_photo': 'Tomar Foto',
      'retake': 'Repetir',
      'save': 'Guardar',
      'share': 'Compartir',
      'compare': 'Comparar',
      'original': 'Original',
      'dot_art': 'Arte Pixel',
      'processing': 'Procesando...',
      'processing_dot_art': 'Generando arte pixel...',
      // 他の翻訳も同様に...
    },
    'de': {
      'app_name': 'DotAnimeCam',
      'camera_title': 'Kamera',
      'gallery_title': 'Galerie',
      'settings_title': 'Einstellungen',
      'take_photo': 'Foto aufnehmen',
      'retake': 'Wiederholen',
      'save': 'Speichern',
      'share': 'Teilen',
      'compare': 'Vergleichen',
      'original': 'Original',
      'dot_art': 'Pixel Art',
      'processing': 'Verarbeitung...',
      'processing_dot_art': 'Pixel Art generieren...',
      // 他の翻訳も同様に...
    },
    'ko': {
      'app_name': 'DotAnimeCam',
      'camera_title': '카메라',
      'gallery_title': '갤러리',
      'settings_title': '설정',
      'take_photo': '사진 촬영',
      'retake': '다시 촬영',
      'save': '저장',
      'share': '공유',
      'compare': '비교',
      'original': '원본',
      'dot_art': '도트 아트',
      'processing': '처리 중...',
      'processing_dot_art': '도트 아트 생성 중...',
      // 他の翻訳も同様に...
    },
    'zh': {
      'app_name': 'DotAnimeCam',
      'camera_title': '相機',
      'gallery_title': '圖庫',
      'settings_title': '設定',
      'take_photo': '拍照',
      'retake': '重拍',
      'save': '儲存',
      'share': '分享',
      'compare': '比較',
      'original': '原始',
      'dot_art': '點陣圖',
      'processing': '處理中...',
      'processing_dot_art': '生成點陣圖中...',
      // 他の翻訳も同様に...
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get cameraTitle =>
      _localizedValues[locale.languageCode]!['camera_title']!;
  String get galleryTitle =>
      _localizedValues[locale.languageCode]!['gallery_title']!;
  String get settingsTitle =>
      _localizedValues[locale.languageCode]!['settings_title']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['take_photo']!;
  String get retake => _localizedValues[locale.languageCode]!['retake']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get share => _localizedValues[locale.languageCode]!['share']!;
  String get compare => _localizedValues[locale.languageCode]!['compare']!;
  String get original => _localizedValues[locale.languageCode]!['original']!;
  String get dotArt => _localizedValues[locale.languageCode]!['dot_art']!;
  String get processing =>
      _localizedValues[locale.languageCode]!['processing']!;
  String get processingDotArt =>
      _localizedValues[locale.languageCode]!['processing_dot_art']!;
  String get savedSuccessfully =>
      _localizedValues[locale.languageCode]!['saved_successfully']!;
  String get saveFailed =>
      _localizedValues[locale.languageCode]!['save_failed']!;
  String get shareFailed =>
      _localizedValues[locale.languageCode]!['share_failed']!;
  String get cameraPermissionRequired =>
      _localizedValues[locale.languageCode]!['camera_permission_required']!;
  String get storagePermissionRequired =>
      _localizedValues[locale.languageCode]!['storage_permission_required']!;
  String get grantPermission =>
      _localizedValues[locale.languageCode]!['grant_permission']!;
  String get settingsOpen =>
      _localizedValues[locale.languageCode]!['settings_open']!;
  String get dotSize => _localizedValues[locale.languageCode]!['dot_size']!;
  String get colorPalette =>
      _localizedValues[locale.languageCode]!['color_palette']!;
  String get comparisonLayout =>
      _localizedValues[locale.languageCode]!['comparison_layout']!;
  String get sideBySide =>
      _localizedValues[locale.languageCode]!['side_by_side']!;
  String get topBottom => _localizedValues[locale.languageCode]!['top_bottom']!;
  String get overlay => _localizedValues[locale.languageCode]!['overlay']!;
  String get autoSave => _localizedValues[locale.languageCode]!['auto_save']!;
  String get saveLocation =>
      _localizedValues[locale.languageCode]!['save_location']!;
  String get deviceStorage =>
      _localizedValues[locale.languageCode]!['device_storage']!;
  String get icloud => _localizedValues[locale.languageCode]!['icloud']!;
  String get googlePhotos =>
      _localizedValues[locale.languageCode]!['google_photos']!;
  String get tutorial => _localizedValues[locale.languageCode]!['tutorial']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get privacyPolicy =>
      _localizedValues[locale.languageCode]!['privacy_policy']!;
  String get termsOfService =>
      _localizedValues[locale.languageCode]!['terms_of_service']!;
  String get onboardingTitle1 =>
      _localizedValues[locale.languageCode]!['onboarding_title_1']!;
  String get onboardingSubtitle1 =>
      _localizedValues[locale.languageCode]!['onboarding_subtitle_1']!;
  String get onboardingTitle2 =>
      _localizedValues[locale.languageCode]!['onboarding_title_2']!;
  String get onboardingSubtitle2 =>
      _localizedValues[locale.languageCode]!['onboarding_subtitle_2']!;
  String get onboardingTitle3 =>
      _localizedValues[locale.languageCode]!['onboarding_title_3']!;
  String get onboardingSubtitle3 =>
      _localizedValues[locale.languageCode]!['onboarding_subtitle_3']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get skip => _localizedValues[locale.languageCode]!['skip']!;
  String get start => _localizedValues[locale.languageCode]!['start']!;
  String get emptyGallery =>
      _localizedValues[locale.languageCode]!['empty_gallery']!;
  String get emptyGallerySubtitle =>
      _localizedValues[locale.languageCode]!['empty_gallery_subtitle']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get deleteConfirmation =>
      _localizedValues[locale.languageCode]!['delete_confirmation']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get errorOccurred =>
      _localizedValues[locale.languageCode]!['error_occurred']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get noCameraAvailable =>
      _localizedValues[locale.languageCode]!['no_camera_available']!;
  String get flipCamera =>
      _localizedValues[locale.languageCode]!['flip_camera']!;
  String get flashAuto => _localizedValues[locale.languageCode]!['flash_auto']!;
  String get flashOn => _localizedValues[locale.languageCode]!['flash_on']!;
  String get flashOff => _localizedValues[locale.languageCode]!['flash_off']!;
  String get qualityHigh =>
      _localizedValues[locale.languageCode]!['quality_high']!;
  String get qualityMedium =>
      _localizedValues[locale.languageCode]!['quality_medium']!;
  String get qualityLow =>
      _localizedValues[locale.languageCode]!['quality_low']!;
  String get gifCreated =>
      _localizedValues[locale.languageCode]!['gif_created']!;
  String get gifCreationFailed =>
      _localizedValues[locale.languageCode]!['gif_creation_failed']!;
  String get comparisonVideo =>
      _localizedValues[locale.languageCode]!['comparison_video']!;
  String get singleImage =>
      _localizedValues[locale.languageCode]!['single_image']!;
  String get bothImages =>
      _localizedValues[locale.languageCode]!['both_images']!;
  String get exportOptions =>
      _localizedValues[locale.languageCode]!['export_options']!;
  String get styleSquare =>
      _localizedValues[locale.languageCode]!['style_square']!;
  String get styleCircle =>
      _localizedValues[locale.languageCode]!['style_circle']!;
  String get styleDiamond =>
      _localizedValues[locale.languageCode]!['style_diamond']!;
  String get stylePixel =>
      _localizedValues[locale.languageCode]!['style_pixel']!;
  String get dotStyle => _localizedValues[locale.languageCode]!['dot_style']!;
  String get resetSettings =>
      _localizedValues[locale.languageCode]!['reset_settings']!;
  String get resetConfirmation =>
      _localizedValues[locale.languageCode]!['reset_confirmation']!;
  String get rateApp => _localizedValues[locale.languageCode]!['rate_app']!;
  String get feedback => _localizedValues[locale.languageCode]!['feedback']!;
  String get help => _localizedValues[locale.languageCode]!['help']!;
  String get cameraError =>
      _localizedValues[locale.languageCode]!['camera_error']!;
  String get cameraInitializationFailed =>
      _localizedValues[locale.languageCode]!['camera_initialization_failed']!;
  String get imageProcessingFailed =>
      _localizedValues[locale.languageCode]!['image_processing_failed']!;
  String get permissionDenied =>
      _localizedValues[locale.languageCode]!['permission_denied']!;
  String get permissionRequiredMessage =>
      _localizedValues[locale.languageCode]!['permission_required_message']!;
  String get cameraPermission =>
      _localizedValues[locale.languageCode]!['camera_permission']!;
  String get storagePermission =>
      _localizedValues[locale.languageCode]!['storage_permission']!;
  String get microphonePermission =>
      _localizedValues[locale.languageCode]!['microphone_permission']!;
  String get trackingPermission =>
      _localizedValues[locale.languageCode]!['tracking_permission']!;
  String get permissionCameraDescription =>
      _localizedValues[locale.languageCode]!['permission_camera_description']!;
  String get permissionStorageDescription =>
      _localizedValues[locale.languageCode]!['permission_storage_description']!;
  String get permissionMicrophoneDescription =>
      _localizedValues[locale
          .languageCode]!['permission_microphone_description']!;
  String get permissionTrackingDescription =>
      _localizedValues[locale
          .languageCode]!['permission_tracking_description']!;
  String get permissionDeniedPermanent =>
      _localizedValues[locale.languageCode]!['permission_denied_permanent']!;
  String get openSettings =>
      _localizedValues[locale.languageCode]!['open_settings']!;
  String get tutorialStep1 =>
      _localizedValues[locale.languageCode]!['tutorial_step_1']!;
  String get tutorialStep2 =>
      _localizedValues[locale.languageCode]!['tutorial_step_2']!;
  String get tutorialStep3 =>
      _localizedValues[locale.languageCode]!['tutorial_step_3']!;
  String get tutorialStep1Description =>
      _localizedValues[locale.languageCode]!['tutorial_step_1_description']!;
  String get tutorialStep2Description =>
      _localizedValues[locale.languageCode]!['tutorial_step_2_description']!;
  String get tutorialStep3Description =>
      _localizedValues[locale.languageCode]!['tutorial_step_3_description']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get preview => _localizedValues[locale.languageCode]!['preview']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get filter => _localizedValues[locale.languageCode]!['filter']!;
  String get brightness =>
      _localizedValues[locale.languageCode]!['brightness']!;
  String get contrast => _localizedValues[locale.languageCode]!['contrast']!;
  String get saturation =>
      _localizedValues[locale.languageCode]!['saturation']!;
  String get reset => _localizedValues[locale.languageCode]!['reset']!;
  String get apply => _localizedValues[locale.languageCode]!['apply']!;
  String get undo => _localizedValues[locale.languageCode]!['undo']!;
  String get redo => _localizedValues[locale.languageCode]!['redo']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'ja',
      'en',
      'it',
      'pt',
      'es',
      'de',
      'ko',
      'zh',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

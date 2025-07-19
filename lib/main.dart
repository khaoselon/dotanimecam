import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io';

import 'screens/camera_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/localization.dart';
import 'utils/constants.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Mobile Ads初期化
  MobileAds.instance.initialize();

  // カメラ初期化
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('カメラの初期化に失敗しました: $e');
  }

  // 縦向き固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(DotAnimeCamApp());
}

class DotAnimeCamApp extends StatefulWidget {
  @override
  _DotAnimeCamAppState createState() => _DotAnimeCamAppState();
}

class _DotAnimeCamAppState extends State<DotAnimeCamApp> {
  Locale _locale = Locale('ja', 'JP');
  bool _isFirstLaunch = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 初回起動チェック
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // 言語設定の読み込み
    final languageCode = prefs.getString('languageCode') ?? 'ja';
    final countryCode = prefs.getString('countryCode') ?? 'JP';
    _locale = Locale(languageCode, countryCode);

    // iOS ATT許可を適切なタイミングで表示
    if (Platform.isIOS && _isFirstLaunch) {
      await Future.delayed(Duration(seconds: 2)); // オンボーディング完了後に表示
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestATTPermission() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    // 言語設定を保存
    _saveLanguagePreference(locale);
  }

  Future<void> _saveLanguagePreference(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'DotAnimeCam',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'DotAnimeCam',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSans',
      ),
      locale: _locale,
      localizationsDelegates: [AppLocalizationsDelegate()],
      supportedLocales: [
        const Locale('ja', 'JP'),
        const Locale('en', 'US'),
        const Locale('it', 'IT'),
        const Locale('pt', 'PT'),
        const Locale('es', 'ES'),
        const Locale('de', 'DE'),
        const Locale('ko', 'KR'),
        const Locale('zh', 'Hant'),
      ],
      home: _isFirstLaunch
          ? OnboardingScreen(
              onComplete: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isFirstLaunch', false);
                await _requestATTPermission();
                setState(() {
                  _isFirstLaunch = false;
                });
              },
            )
          : CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

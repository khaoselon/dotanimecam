// services/ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AdService {
  static AdService? _instance;
  AdService._internal();

  factory AdService() {
    _instance ??= AdService._internal();
    return _instance!;
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _interstitialAdRetryAttempt = 0;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  int _rewardedAdRetryAttempt = 0;

  // 広告設定
  bool _adsEnabled = true;
  int _adFrequency = AppConstants.interstitialAdInterval;

  // 初期化
  Future<void> initialize() async {
    await _loadAdSettings();
    if (_adsEnabled) {
      _createInterstitialAd();
      _createRewardedAd();
    }
  }

  // 広告設定を読み込み
  Future<void> _loadAdSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _adsEnabled = prefs.getBool('ads_enabled') ?? true;
    _adFrequency =
        prefs.getInt('ad_frequency') ?? AppConstants.interstitialAdInterval;
  }

  // 広告設定を保存
  Future<void> saveAdSettings({bool? adsEnabled, int? adFrequency}) async {
    final prefs = await SharedPreferences.getInstance();

    if (adsEnabled != null) {
      _adsEnabled = adsEnabled;
      await prefs.setBool('ads_enabled', adsEnabled);
    }

    if (adFrequency != null) {
      _adFrequency = adFrequency;
      await prefs.setInt('ad_frequency', adFrequency);
    }
  }

  // インタースティシャル広告を作成
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('インタースティシャル広告が読み込まれました');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialAdRetryAttempt = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              print('インタースティシャル広告が表示されました');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('インタースティシャル広告が閉じられました');
              ad.dispose();
              _isInterstitialAdReady = false;
              _createInterstitialAd();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
                  print('インタースティシャル広告の表示に失敗しました: $error');
                  ad.dispose();
                  _isInterstitialAdReady = false;
                  _createInterstitialAd();
                },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('インタースティシャル広告の読み込みに失敗しました: $error');
          _isInterstitialAdReady = false;
          _interstitialAdRetryAttempt++;

          if (_interstitialAdRetryAttempt < 3) {
            Future.delayed(
              Duration(seconds: _interstitialAdRetryAttempt * 5),
              () {
                _createInterstitialAd();
              },
            );
          }
        },
      ),
    );
  }

  // リワード広告を作成
  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // テスト用リワード広告ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('リワード広告が読み込まれました');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _rewardedAdRetryAttempt = 0;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedAd ad) {
              print('リワード広告が表示されました');
            },
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              print('リワード広告が閉じられました');
              ad.dispose();
              _isRewardedAdReady = false;
              _createRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              print('リワード広告の表示に失敗しました: $error');
              ad.dispose();
              _isRewardedAdReady = false;
              _createRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('リワード広告の読み込みに失敗しました: $error');
          _isRewardedAdReady = false;
          _rewardedAdRetryAttempt++;

          if (_rewardedAdRetryAttempt < 3) {
            Future.delayed(Duration(seconds: _rewardedAdRetryAttempt * 5), () {
              _createRewardedAd();
            });
          }
        },
      ),
    );
  }

  // インタースティシャル広告を表示
  Future<void> showInterstitialAd() async {
    if (!_adsEnabled || !_isInterstitialAdReady || _interstitialAd == null) {
      print('インタースティシャル広告を表示できません');
      return;
    }

    try {
      await _interstitialAd!.show();
    } catch (e) {
      print('インタースティシャル広告表示エラー: $e');
    }
  }

  // リワード広告を表示
  Future<bool> showRewardedAd() async {
    if (!_adsEnabled || !_isRewardedAdReady || _rewardedAd == null) {
      print('リワード広告を表示できません');
      return false;
    }

    bool rewardEarned = false;

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('リワード獲得: ${reward.type} ${reward.amount}');
          rewardEarned = true;
        },
      );
    } catch (e) {
      print('リワード広告表示エラー: $e');
    }

    return rewardEarned;
  }

  // 広告頻度チェック
  Future<bool> shouldShowAd() async {
    if (!_adsEnabled) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastAdTime = prefs.getInt('last_ad_time') ?? 0;
    final photoCount = prefs.getInt('photo_count') ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceLastAd = now - lastAdTime;
    const minAdInterval = 30000; // 30秒

    // 最低時間間隔と写真撮影回数の両方をチェック
    if (timeSinceLastAd > minAdInterval && photoCount % _adFrequency == 0) {
      await prefs.setInt('last_ad_time', now);
      return true;
    }

    return false;
  }

  // 写真撮影回数を記録
  Future<void> recordPhotoTaken() async {
    final prefs = await SharedPreferences.getInstance();
    final photoCount = prefs.getInt('photo_count') ?? 0;
    await prefs.setInt('photo_count', photoCount + 1);
  }

  // バナー広告を作成
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('バナー広告が読み込まれました');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('バナー広告の読み込みに失敗しました: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          print('バナー広告が開かれました');
        },
        onAdClosed: (Ad ad) {
          print('バナー広告が閉じられました');
        },
      ),
    );
  }

  // 広告無効化（アプリ内課金用）
  Future<void> disableAds() async {
    _adsEnabled = false;
    await saveAdSettings(adsEnabled: false);

    // 既存の広告を破棄
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();

    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialAdReady = false;
    _isRewardedAdReady = false;
  }

  // リソース解放
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

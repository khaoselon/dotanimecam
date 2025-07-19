# 🎨 DotAnimeCam - ドット絵変換カメラアプリ

> **ワンタップ撮影で"ゲームアニメ風ドット絵"へ変換**

[![Flutter](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 アプリ概要

DotAnimeCam は、撮影した写真を瞬時にアニメ風ドット絵に変換するカメラアプリです。懐かしいレトロゲームの世界観を現代に蘇らせ、SNSで注目を集める「映える」コンテンツを簡単に作成できます。

### 🎯 ターゲットユーザー
- **10〜20代**: SNSヘビーユーザー（映える画像を投稿したい）
- **30〜40代**: レトロゲーム好き（懐かしいドット感を楽しみたい）
- **IT初心者**: 説明不要でも直感的に使える操作性

### 🌍 多言語対応
日本語、英語、イタリア語、ポルトガル語、スペイン語、ドイツ語、韓国語、繁体字中国語

## ✨ 主要機能

### 📸 撮影機能
- **ワンタップ撮影**: シンプルなカメラインターフェース
- **カメラ切り替え**: フロント/リアカメラ対応
- **フラッシュ制御**: 自動/ON/OFF切り替え
- **フォーカス調整**: タップでピント合わせ

### 🎨 ドット絵変換
- **リアルタイム変換**: 撮影後即座にドット絵生成
- **カスタマイズ可能**: ドットサイズ、カラーパレット調整
- **4種類のドットスタイル**: 四角、円、ダイヤモンド、ピクセル
- **アニメ風効果**: 彩度・コントラスト強化

### 🔄 比較表示
- **フリップアニメーション**: Y軸中心の回転で比較
- **3種類のレイアウト**: 左右比較、上下比較、オーバーレイ
- **スムーズな切り替え**: 60fps の流れるようなアニメーション

### 💾 保存・共有
- **複数の保存形式**: 単体画像、比較GIF、動画
- **SNS連携**: X, Instagram, LINE, AirDrop対応
- **ギャラリー機能**: アプリ内で作品を管理

### ⚙️ 設定機能
- **詳細カスタマイズ**: ドット絵の品質調整
- **言語切り替え**: 8言語対応
- **自動保存**: 撮影後の自動保存設定

## 🛠️ 技術仕様

### 開発環境
- **Flutter**: 3.32.0 (Beta Channel)
- **Dart**: 3.0+
- **IDE**: Android Studio / VS Code

### 対応プラットフォーム
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+

### 主要依存関係
```yaml
dependencies:
  flutter_localizations: ^1.0.0
  camera: ^0.10.5+9
  image: ^4.1.3
  google_mobile_ads: ^4.0.0
  permission_handler: ^11.1.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  share_plus: ^7.2.1
```

## 🚀 セットアップ手順

### 1. 前提条件
```bash
# Flutter SDK インストール確認
flutter --version
# Flutter (Channel beta, 3.32.0-0.2.pre, on macOS 14.7.5)

# 依存関係インストール
flutter pub get
```

### 2. プロジェクトクローン
```bash
git clone https://github.com/your-username/dotanimecam.git
cd dotanimecam
flutter pub get
```

### 3. 環境設定

#### Android
```bash
# Android Studio で以下を設定
# - SDK Platform 34
# - Android SDK Build-Tools 34.0.0
# - Java 8 以上

# 署名キー生成（リリース時）
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

#### iOS
```bash
# Xcode で以下を設定
# - Development Team
# - Bundle Identifier: com.dotanimecam.app
# - Deployment Target: iOS 12.0

cd ios && pod install
```

### 4. 実行
```bash
# デバッグ実行
flutter run

# リリースビルド
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📁 プロジェクト構成

```
dotanimecam/
├── lib/
│   ├── main.dart                 # アプリエントリーポイント
│   ├── screens/                  # UI画面
│   │   ├── camera_screen.dart    # メインカメラ画面
│   │   ├── preview_screen.dart   # プレビュー・比較画面
│   │   ├── gallery_screen.dart   # ギャラリー画面
│   │   ├── settings_screen.dart  # 設定画面
│   │   └── onboarding_screen.dart # オンボーディング
│   ├── widgets/                  # カスタムウィジェット
│   │   ├── comparison_card.dart  # 比較表示カード
│   │   ├── gallery_item_widget.dart # ギャラリーアイテム
│   │   └── custom_widgets.dart   # 共通ウィジェット
│   ├── services/                 # ビジネスロジック
│   │   ├── dot_art_service.dart  # ドット絵変換エンジン
│   │   ├── camera_service.dart   # カメラ制御
│   │   ├── storage_service.dart  # ストレージ管理
│   │   ├── gif_service.dart      # GIF作成
│   │   └── ad_service.dart       # 広告管理
│   └── utils/                    # ユーティリティ
│       ├── constants.dart        # 定数・設定
│       ├── localization.dart     # 多言語対応
│       └── error_handling.dart   # エラーハンドリング
├── android/                      # Android固有設定
├── ios/                          # iOS固有設定
└── pubspec.yaml                  # 依存関係設定
```

## 🎨 カスタマイズ方法

### 1. 色・テーマ変更
```dart
// lib/utils/constants.dart
class AppColors {
  static const Color primary = Color(0xFF6B73FF);      // メインカラー
  static const Color secondary = Color(0xFFFF6B9D);    // セカンダリカラー
  static const Color background = Color(0xFFF8F9FA);   // 背景色
  // ... その他の色設定
}
```

### 2. ドット絵設定調整
```dart
// lib/utils/constants.dart
class AppConstants {
  static const int defaultDotSize = 8;           // デフォルトドットサイズ
  static const int defaultColorPalette = 16;     // デフォルトカラーパレット
  static const int interstitialAdInterval = 5;   // 広告表示間隔
  // ... その他の設定
}
```

### 3. 新しい言語追加
```dart
// lib/utils/localization.dart
static const _localizedValues = <String, Map<String, String>>{
  'your_language': {
    'app_name': 'Your App Name',
    'camera_title': 'Your Camera Title',
    // ... 翻訳を追加
  },
};
```

## 🔒 権限とセキュリティ

### 必要な権限
- **カメラ**: 写真撮影
- **ストレージ**: 画像保存
- **マイク**: 動画撮影（オプション）
- **App Tracking Transparency**: 広告最適化（iOS）

### プライバシー保護
- ローカルストレージのみ使用
- 外部サーバーへのデータ送信なし
- 必要最小限の権限のみリクエスト

## 💰 収益モデル

### 広告配置
- **バナー広告**: ギャラリー下部（常時表示）
- **インタースティシャル**: 連続撮影5枚ごと、シェア後

### 設定可能項目
```dart
// lib/services/ad_service.dart
class AdService {
  // 広告表示頻度をRemote Configで調整可能
  static const String bannerAdUnitId = 'your-banner-ad-unit-id';
  static const String interstitialAdUnitId = 'your-interstitial-ad-unit-id';
}
```

## 📊 パフォーマンス最適化

### 画像処理
- **非同期処理**: バックグラウンドで変換実行
- **メモリ効率**: 適切なリサイズとキャッシュ管理
- **プログレス表示**: ユーザーへの進捗フィードバック

### UI/UX
- **60fps**: スムーズなアニメーション
- **レスポンシブ**: 様々な画面サイズに対応
- **ローディング**: 適切な待機時間表示

## 🐛 トラブルシューティング

### よくある問題

#### 1. カメラが起動しない
```bash
# 権限確認
flutter run --verbose
# AndroidManifest.xml / Info.plist の権限設定を確認
```

#### 2. ビルドエラー
```bash
# 依存関係のクリーンアップ
flutter clean
flutter pub get
flutter pub upgrade
```

#### 3. iOS シミュレーターでカメラが使用できない
```bash
# 実機でのテストが必要
flutter run -d [device-id]
```

### エラーレポート
```dart
// lib/utils/error_handling.dart
ErrorHandler.handleError(error, stackTrace, context);
```

## 🤝 コントリビューション

### 開発に参加する
1. Fork このリポジトリ
2. Feature ブランチ作成 (`git checkout -b feature/amazing-feature`)
3. Commit 変更 (`git commit -m 'Add amazing feature'`)
4. Push ブランチ (`git push origin feature/amazing-feature`)
5. Pull Request 作成

### コーディング規約
- Dart の公式スタイルガイドに従う
- 日本語コメントを推奨
- 適切なエラーハンドリングを実装

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 🙏 謝辞

- **Flutter Team**: 素晴らしいフレームワークの提供
- **image package**: 画像処理ライブラリ
- **Google Mobile Ads**: 広告プラットフォーム
- **コミュニティ**: バグレポートと改善提案

## 📞 サポート

### 問題報告
- **GitHub Issues**: [Issues](https://github.com/your-username/dotanimecam/issues)
- **メール**: support@dotanimecam.com

### ドキュメント
- **技術仕様**: [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- **API リファレンス**: [/docs](docs/)

---

**DotAnimeCam** で、あなたの写真を魔法のようなドット絵に変換しましょう！ 🎨✨

Made with ❤️ by DotAnimeCam Team
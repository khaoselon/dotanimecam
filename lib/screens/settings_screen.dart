import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/custom_widgets.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../widgets/settings_widgets.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  final StorageService _storageService = StorageService();
  final AdService _adService = AdService();

  // 設定値
  int _dotSize = AppConstants.defaultDotSize;
  int _colorPalette = AppConstants.defaultColorPalette;
  DotStyle _dotStyle = DotStyle.square;
  ComparisonLayout _comparisonLayout = ComparisonLayout.sideBySide;
  bool _autoSave = true;
  bool _showTutorial = true;
  String _language = 'ja';
  String _theme = 'system';

  // アプリ情報
  String _appVersion = '';
  String _buildNumber = '';
  int _storageUsage = 0;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.loadSettings();
    final storageUsage = await _storageService.getStorageUsage();

    setState(() {
      _dotSize = settings['dot_size'] ?? AppConstants.defaultDotSize;
      _colorPalette =
          settings['color_palette'] ?? AppConstants.defaultColorPalette;
      _dotStyle = DotStyle.values[settings['dot_style'] ?? 0];
      _comparisonLayout =
          ComparisonLayout.values[settings['comparison_layout'] ?? 0];
      _autoSave = settings['auto_save'] ?? true;
      _showTutorial = settings['show_tutorial'] ?? true;
      _language = settings['language'] ?? 'ja';
      _theme = settings['theme'] ?? 'system';
      _storageUsage = storageUsage;
      _isLoading = false;
    });
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _saveSettings() async {
    final settings = {
      'dot_size': _dotSize,
      'color_palette': _colorPalette,
      'dot_style': _dotStyle.index,
      'comparison_layout': _comparisonLayout.index,
      'auto_save': _autoSave,
      'show_tutorial': _showTutorial,
      'language': _language,
      'theme': _theme,
    };

    await _storageService.saveSettings(settings);
  }

  Future<void> _resetSettings() async {
    final localizations = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.resetSettings),
        content: Text(localizations.resetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.confirm),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _dotSize = AppConstants.defaultDotSize;
        _colorPalette = AppConstants.defaultColorPalette;
        _dotStyle = DotStyle.square;
        _comparisonLayout = ComparisonLayout.sideBySide;
        _autoSave = true;
        _showTutorial = true;
        _language = 'ja';
        _theme = 'system';
      });

      await _saveSettings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('設定をリセットしました'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    try {
      await _storageService.clearCache();
      final newStorageUsage = await _storageService.getStorageUsage();

      setState(() {
        _storageUsage = newStorageUsage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('キャッシュをクリアしました'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('キャッシュクリアに失敗しました'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showTutorialDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          onComplete: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetSettings),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          // ドット絵設定
          _buildDotArtSettings(localizations),

          SizedBox(height: AppDimensions.paddingLarge),

          // 表示設定
          _buildDisplaySettings(localizations),

          SizedBox(height: AppDimensions.paddingLarge),

          // 一般設定
          _buildGeneralSettings(localizations),

          SizedBox(height: AppDimensions.paddingLarge),

          // ストレージ設定
          _buildStorageSettings(localizations),

          SizedBox(height: AppDimensions.paddingLarge),

          // アプリ情報
          _buildAppInfo(localizations),

          SizedBox(height: AppDimensions.paddingLarge),

          // リセットボタン
          CustomButton(
            text: localizations.resetSettings,
            onPressed: _resetSettings,
            backgroundColor: AppColors.error,
            textColor: AppColors.surface,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildDotArtSettings(AppLocalizations localizations) {
    return SettingsSection(
      title: 'ドット絵設定',
      icon: Icons.auto_fix_high,
      children: [
        // ドットサイズ
        SettingsItem(
          title: localizations.dotSize,
          subtitle: '${_dotSize}px',
          child: CustomSlider(
            value: _dotSize.toDouble(),
            min: AppConstants.minDotSize.toDouble(),
            max: AppConstants.maxDotSize.toDouble(),
            divisions: AppConstants.maxDotSize - AppConstants.minDotSize,
            label: localizations.dotSize,
            onChanged: (value) {
              setState(() {
                _dotSize = value.toInt();
              });
              _saveSettings();
            },
          ),
        ),

        // カラーパレット
        SettingsItem(
          title: localizations.colorPalette,
          subtitle: '${_colorPalette}色',
          child: CustomSlider(
            value: _colorPalette.toDouble(),
            min: AppConstants.minColorPalette.toDouble(),
            max: AppConstants.maxColorPalette.toDouble(),
            divisions:
                (AppConstants.maxColorPalette - AppConstants.minColorPalette) ~/
                4,
            label: localizations.colorPalette,
            onChanged: (value) {
              setState(() {
                _colorPalette = value.toInt();
              });
              _saveSettings();
            },
          ),
        ),

        // ドットスタイル
        SettingsItem(
          title: localizations.dotStyle,
          subtitle: _getDotStyleName(_dotStyle),
          child: _buildDotStyleSelector(),
        ),
      ],
    );
  }

  Widget _buildDisplaySettings(AppLocalizations localizations) {
    return SettingsSection(
      title: '表示設定',
      icon: Icons.display_settings,
      children: [
        // 比較レイアウト
        SettingsItem(
          title: localizations.comparisonLayout,
          subtitle: _getComparisonLayoutName(_comparisonLayout),
          child: _buildComparisonLayoutSelector(),
        ),

        // 言語設定
        SettingsItem(
          title: localizations.language,
          subtitle: AppSettings.supportedLanguages[_language] ?? 'Japanese',
          child: _buildLanguageSelector(),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings(AppLocalizations localizations) {
    return SettingsSection(
      title: '一般設定',
      icon: Icons.settings,
      children: [
        // 自動保存
        SettingsItem(
          title: localizations.autoSave,
          subtitle: '撮影後に自動で保存',
          child: CustomSwitch(
            value: _autoSave,
            onChanged: (value) {
              setState(() {
                _autoSave = value;
              });
              _saveSettings();
            },
            label: '',
          ),
        ),

        // チュートリアル表示
        SettingsItem(
          title: localizations.tutorial,
          subtitle: 'チュートリアルを再表示',
          onTap: _showTutorial,
          trailing: Icon(Icons.arrow_forward_ios),
        ),

        // ヘルプ
        SettingsItem(
          title: localizations.help,
          subtitle: 'よくある質問',
          onTap: () => _openUrl('https://example.com/help'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),

        // フィードバック
        SettingsItem(
          title: localizations.feedback,
          subtitle: 'ご意見・ご要望',
          onTap: () => _openUrl('https://example.com/feedback'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget _buildStorageSettings(AppLocalizations localizations) {
    return SettingsSection(
      title: 'ストレージ',
      icon: Icons.storage,
      children: [
        // ストレージ使用量
        SettingsItem(
          title: 'ストレージ使用量',
          subtitle: _formatStorageSize(_storageUsage),
          trailing: Icon(Icons.info_outline),
        ),

        // キャッシュクリア
        SettingsItem(
          title: 'キャッシュクリア',
          subtitle: '一時ファイルを削除',
          onTap: _clearCache,
          trailing: Icon(Icons.cleaning_services),
        ),
      ],
    );
  }

  Widget _buildAppInfo(AppLocalizations localizations) {
    return SettingsSection(
      title: localizations.about,
      icon: Icons.info,
      children: [
        // アプリバージョン
        SettingsItem(
          title: localizations.version,
          subtitle: '$_appVersion ($_buildNumber)',
          trailing: Icon(Icons.info_outline),
        ),

        // プライバシーポリシー
        SettingsItem(
          title: localizations.privacyPolicy,
          subtitle: 'プライバシーポリシー',
          onTap: () => _openUrl('https://example.com/privacy'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),

        // 利用規約
        SettingsItem(
          title: localizations.termsOfService,
          subtitle: '利用規約',
          onTap: () => _openUrl('https://example.com/terms'),
          trailing: Icon(Icons.arrow_forward_ios),
        ),

        // アプリ評価
        SettingsItem(
          title: localizations.rateApp,
          subtitle: 'App Store / Google Play',
          onTap: () => _openUrl(
            Platform.isIOS
                ? 'https://apps.apple.com/app/id123456789'
                : 'https://play.google.com/store/apps/details?id=com.example.dotanimecam',
          ),
          trailing: Icon(Icons.star),
        ),
      ],
    );
  }

  Widget _buildDotStyleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: DotStyle.values.map((style) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _dotStyle = style;
            });
            _saveSettings();
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: _dotStyle == style
                    ? AppColors.primary
                    : AppColors.divider,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Center(child: _buildDotStyleIcon(style)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDotStyleIcon(DotStyle style) {
    switch (style) {
      case DotStyle.square:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case DotStyle.circle:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        );
      case DotStyle.diamond:
        return Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      case DotStyle.pixel:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: AppColors.primary),
        );
    }
  }

  Widget _buildComparisonLayoutSelector() {
    return Column(
      children: ComparisonLayout.values.map((layout) {
        return RadioListTile<ComparisonLayout>(
          title: Text(_getComparisonLayoutName(layout)),
          value: layout,
          groupValue: _comparisonLayout,
          onChanged: (value) {
            setState(() {
              _comparisonLayout = value!;
            });
            _saveSettings();
          },
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      children: AppSettings.supportedLanguages.entries.map((entry) {
        return RadioListTile<String>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _language,
          onChanged: (value) {
            setState(() {
              _language = value!;
            });
            _saveSettings();
          },
        );
      }).toList(),
    );
  }

  String _getDotStyleName(DotStyle style) {
    switch (style) {
      case DotStyle.square:
        return '四角';
      case DotStyle.circle:
        return '円';
      case DotStyle.diamond:
        return 'ダイヤモンド';
      case DotStyle.pixel:
        return 'ピクセル';
    }
  }

  String _getComparisonLayoutName(ComparisonLayout layout) {
    switch (layout) {
      case ComparisonLayout.sideBySide:
        return '左右比較';
      case ComparisonLayout.topBottom:
        return '上下比較';
      case ComparisonLayout.overlay:
        return 'オーバーレイ';
    }
  }

  String _formatStorageSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

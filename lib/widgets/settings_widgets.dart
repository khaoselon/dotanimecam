import 'package:flutter/material.dart';
import '../utils/constants.dart';

// 設定セクション
class SettingsSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final Color? iconColor;

  const SettingsSection({
    Key? key,
    required this.title,
    this.icon,
    required this.children,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Container(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: AppDimensions.iconSizeMedium,
                  ),
                  SizedBox(width: AppDimensions.paddingSmall),
                ],
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // セクションコンテンツ
          ...children,
        ],
      ),
    );
  }
}

// 設定項目
class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? titleColor;
  final Color? subtitleColor;

  const SettingsItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.child,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.titleColor,
    this.subtitleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル行
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: enabled
                                  ? (titleColor ?? AppColors.textPrimary)
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: enabled
                                    ? (subtitleColor ?? AppColors.textSecondary)
                                    : AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      SizedBox(width: AppDimensions.paddingSmall),
                      trailing!,
                    ],
                  ],
                ),

                // 子ウィジェット
                if (child != null) ...[
                  SizedBox(height: AppDimensions.paddingMedium),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 設定グループ
class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? padding;

  const SettingsGroup({
    Key? key,
    this.title,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding ?? EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.paddingMedium,
                bottom: AppDimensions.paddingSmall,
              ),
              child: Text(
                title!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// 設定スイッチ項目
class SettingsSwitchItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final Color? activeColor;

  const SettingsSwitchItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: activeColor ?? AppColors.primary,
      ),
    );
  }
}

// 設定スライダー項目
class SettingsSliderItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? labelFormatter;
  final bool enabled;

  const SettingsSliderItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.labelFormatter,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelFormatter?.call(min) ?? min.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                labelFormatter?.call(value) ?? value.toStringAsFixed(0),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                labelFormatter?.call(max) ?? max.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}

// 設定選択項目
class SettingsSelectionItem<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const SettingsSelectionItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      child: Column(
        children: options.map((option) {
          return RadioListTile<T>(
            title: Text(labelBuilder(option)),
            value: option,
            groupValue: value,
            onChanged: enabled
                ? (T? newValue) {
                    if (newValue != null) {
                      onChanged(newValue);
                    }
                  }
                : null,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }
}

// 設定ボタン項目
class SettingsButtonItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool enabled;
  final bool destructive;

  const SettingsButtonItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.onPressed,
    this.icon,
    this.color,
    this.enabled = true,
    this.destructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = destructive
        ? AppColors.error
        : (color ?? AppColors.primary);

    return SettingsItem(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      titleColor: effectiveColor,
      onTap: enabled ? onPressed : null,
      trailing: icon != null
          ? Icon(
              icon,
              color: enabled ? effectiveColor : AppColors.textSecondary,
              size: AppDimensions.iconSizeMedium,
            )
          : null,
    );
  }
}

// 設定情報項目
class SettingsInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool copyable;

  const SettingsInfoItem({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.onTap,
    this.copyable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: value,
      onTap: copyable ? _copyToClipboard : onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (copyable)
            Icon(
              Icons.copy,
              size: AppDimensions.iconSizeSmall,
              color: AppColors.textSecondary,
            ),
          if (icon != null) ...[
            if (copyable) SizedBox(width: AppDimensions.paddingSmall / 2),
            Icon(
              icon,
              size: AppDimensions.iconSizeMedium,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard() {
    // クリップボードにコピーする実装
    // 実際の実装では Clipboard.setData を使用
  }
}

// 設定プログレス項目
class SettingsProgressItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color? progressColor;
  final String? progressText;

  const SettingsProgressItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.progressColor,
    this.progressText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '進捗',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                progressText ?? '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: progressColor ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.paddingSmall / 2),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// 設定セパレーター
class SettingsSeparator extends StatelessWidget {
  final double height;
  final Color? color;

  const SettingsSeparator({Key? key, this.height = 1.0, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color ?? AppColors.divider.withOpacity(0.3),
    );
  }
}

// 設定ヘッダー
class SettingsHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SettingsHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading2),
                if (subtitle != null) ...[
                  SizedBox(height: AppDimensions.paddingSmall / 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppDimensions.paddingMedium),
            trailing!,
          ],
        ],
      ),
    );
  }
}

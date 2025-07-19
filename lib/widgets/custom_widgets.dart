import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

// カスタムボタン
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final double borderRadius;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.surface,
    this.borderColor,
    this.width,
    this.height,
    this.icon,
    this.borderRadius = AppDimensions.radiusMedium,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.fadeInDuration,
      width: width,
      height: height ?? AppDimensions.buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: borderColor ?? backgroundColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                elevation: AppDimensions.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSizeMedium),
          SizedBox(width: AppDimensions.paddingSmall),
          Text(text, style: AppTextStyles.button.copyWith(color: textColor)),
        ],
      );
    }

    return Text(text, style: AppTextStyles.button.copyWith(color: textColor));
  }
}

// アニメーション付きページインジケーター
class AnimatedPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedPageIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.divider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: AppConstants.fadeInDuration,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          width: index == currentPage ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: index == currentPage ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}

// 権限ダイアログ
class PermissionDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const PermissionDialog({
    Key? key,
    required this.onRetry,
    required this.onOpenSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: AppDimensions.iconSizeLarge,
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Text(localizations.permissionDenied, style: AppTextStyles.heading3),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.permissionRequiredMessage,
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          _buildPermissionItem(
            Icons.camera_alt,
            localizations.cameraPermission,
            localizations.permissionCameraDescription,
          ),
          _buildPermissionItem(
            Icons.storage,
            localizations.storagePermission,
            localizations.permissionStorageDescription,
          ),
          _buildPermissionItem(
            Icons.mic,
            localizations.microphonePermission,
            localizations.permissionMicrophoneDescription,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onOpenSettings,
          child: Text(localizations.openSettings),
        ),
        CustomButton(text: localizations.retry, onPressed: onRetry, height: 36),
      ],
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSizeMedium,
            color: AppColors.primary,
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// カスタムローディング
class CustomLoading extends StatelessWidget {
  final String? message;
  final Color color;

  const CustomLoading({Key? key, this.message, this.color = AppColors.primary})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: AppDimensions.paddingMedium),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// カスタムスライダー
class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final Color thumbColor;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
    this.activeColor = AppColors.primary,
    this.thumbColor = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: activeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            thumbColor: thumbColor,
            overlayColor: activeColor.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeStart: (value) {
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
    );
  }
}

// カスタムスイッチ
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? description;
  final Color activeColor;

  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
    this.activeColor = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description != null) ...[
                    SizedBox(height: 2),
                    Text(description!, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
            ),
          ],
        ),
      ),
    );
  }
}

// カスタムセクション
class CustomSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color iconColor;

  const CustomSection({
    Key? key,
    required this.title,
    required this.children,
    this.icon,
    this.iconColor = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: AppDimensions.iconSizeMedium),
              SizedBox(width: AppDimensions.paddingSmall),
            ],
            Text(title, style: AppTextStyles.heading3),
          ],
        ),
        SizedBox(height: AppDimensions.paddingMedium),
        ...children,
      ],
    );
  }
}

// カスタムタブ
class CustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CustomTab({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.fadeInDuration,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                size: AppDimensions.iconSizeSmall,
              ),
              SizedBox(width: AppDimensions.paddingSmall / 2),
            ],
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// エラー表示ウィジェット
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.error),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            message,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppDimensions.paddingLarge),
            CustomButton(
              text: localizations.retry,
              onPressed: onRetry,
              icon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

// 空の状態表示ウィジェット
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            title,
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            SizedBox(height: AppDimensions.paddingLarge),
            CustomButton(text: actionText!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

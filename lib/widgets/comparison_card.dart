import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math' as math;

import '../utils/constants.dart';
import '../utils/localization.dart';

class ComparisonCard extends StatelessWidget {
  final Uint8List originalImage;
  final Uint8List dotArtImage;
  final Animation<double> animation;
  final bool isFlipped;
  final ComparisonLayout layout;

  const ComparisonCard({
    Key? key,
    required this.originalImage,
    required this.dotArtImage,
    required this.animation,
    required this.isFlipped,
    required this.layout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case ComparisonLayout.sideBySide:
        return _buildSideBySideLayout(context);
      case ComparisonLayout.topBottom:
        return _buildTopBottomLayout(context);
      case ComparisonLayout.overlay:
        return _buildOverlayLayout(context);
      default:
        return _buildFlipCardLayout(context);
    }
  }

  Widget _buildFlipCardLayout(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final isShowingFront = animation.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(animation.value * math.pi),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Stack(
                children: [
                  // 背面（ドット絵）
                  if (!isShowingFront)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _buildImageWithLabel(
                        dotArtImage,
                        AppLocalizations.of(context)!.dotArt,
                        AppColors.secondary,
                      ),
                    ),

                  // 前面（オリジナル）
                  if (isShowingFront)
                    _buildImageWithLabel(
                      originalImage,
                      AppLocalizations.of(context)!.original,
                      AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideBySideLayout(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ラベル
          Container(
            padding: EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.original,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(width: 1, height: 16, color: AppColors.divider),
                Expanded(
                  child: Text(
                    localizations.dotArt,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 画像比較
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImageContainer(originalImage)),
                Container(width: 1, color: AppColors.divider),
                Expanded(child: _buildImageContainer(dotArtImage)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBottomLayout(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // オリジナル画像
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: Text(
                    localizations.original,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: _buildImageContainer(originalImage)),
              ],
            ),
          ),

          // 区切り線
          Container(height: 1, color: AppColors.divider),

          // ドット絵
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(color: AppColors.background),
                  child: Text(
                    localizations.dotArt,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: _buildImageContainer(dotArtImage)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayLayout(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Stack(
              children: [
                // 背景画像（常にオリジナル）
                _buildImageContainer(originalImage),

                // オーバーレイ画像（ドット絵）
                AnimatedOpacity(
                  opacity: isFlipped ? 1.0 : 0.0,
                  duration: AppConstants.fadeInDuration,
                  child: _buildImageContainer(dotArtImage),
                ),

                // ラベル
                _buildOverlayLabel(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWithLabel(
    Uint8List imageBytes,
    String label,
    Color labelColor,
  ) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.memory(imageBytes, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContainer(Uint8List imageBytes) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.memory(imageBytes, fit: BoxFit.cover),
    );
  }

  Widget _buildOverlayLabel(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Positioned(
      top: AppDimensions.paddingMedium,
      left: AppDimensions.paddingMedium,
      child: AnimatedContainer(
        duration: AppConstants.fadeInDuration,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall / 2,
        ),
        decoration: BoxDecoration(
          color: isFlipped ? AppColors.secondary : AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          isFlipped ? localizations.dotArt : localizations.original,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// アクションボタン行のウィジェット
class ActionButtonRow extends StatelessWidget {
  final VoidCallback onRetake;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onCompare;
  final bool isProcessing;
  final bool isSaving;
  final bool isSharing;

  const ActionButtonRow({
    Key? key,
    required this.onRetake,
    required this.onSave,
    required this.onShare,
    required this.onCompare,
    required this.isProcessing,
    required this.isSaving,
    required this.isSharing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // メインアクションボタン
          Row(
            children: [
              // 撮り直しボタン
              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh,
                  label: localizations.retake,
                  onPressed: isProcessing ? null : onRetake,
                  backgroundColor: AppColors.surface,
                  textColor: AppColors.textPrimary,
                  borderColor: AppColors.divider,
                ),
              ),

              SizedBox(width: AppDimensions.paddingMedium),

              // 保存ボタン
              Expanded(
                child: _buildActionButton(
                  icon: Icons.save,
                  label: localizations.save,
                  onPressed: isProcessing ? null : onSave,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.surface,
                  isLoading: isSaving,
                ),
              ),

              SizedBox(width: AppDimensions.paddingMedium),

              // シェアボタン
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: localizations.share,
                  onPressed: isProcessing ? null : onShare,
                  backgroundColor: AppColors.secondary,
                  textColor: AppColors.surface,
                  isLoading: isSharing,
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.paddingMedium),

          // 比較ボタン
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              icon: Icons.compare,
              label: localizations.compare,
              onPressed: isProcessing ? null : onCompare,
              backgroundColor: AppColors.background,
              textColor: AppColors.textPrimary,
              borderColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: borderColor != null ? 0 : AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
          horizontal: AppDimensions.paddingSmall,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppDimensions.iconSizeMedium),
                SizedBox(height: 4),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

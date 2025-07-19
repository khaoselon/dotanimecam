import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';

import '../utils/constants.dart';
import '../services/storage_service.dart';

class GalleryItemWidget extends StatefulWidget {
  final GalleryItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GalleryItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  _GalleryItemWidgetState createState() => _GalleryItemWidgetState();
}

class _GalleryItemWidgetState extends State<GalleryItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.fadeInDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.item.filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? 0.95 : 1.0,
            child: AnimatedContainer(
              duration: AppConstants.fadeInDuration,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: widget.isSelected ? 15 : 5,
                    offset: Offset(0, widget.isSelected ? 5 : 2),
                  ),
                ],
              ),
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildItemContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        color: AppColors.surface,
        child: Stack(
          children: [
            // 画像コンテンツ
            Positioned.fill(child: _buildImageContent()),

            // 選択状態のオーバーレイ
            if (widget.isSelectionMode)
              Positioned.fill(child: _buildSelectionOverlay()),

            // タイプインジケーター
            Positioned(
              top: AppDimensions.paddingSmall,
              right: AppDimensions.paddingSmall,
              child: _buildTypeIndicator(),
            ),

            // 日付ラベル
            Positioned(bottom: 0, left: 0, right: 0, child: _buildDateLabel()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError || _imageBytes == null) {
      return _buildErrorState();
    }

    return Image.memory(
      _imageBytes!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: AppColors.error,
              size: AppDimensions.iconSizeLarge,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'エラー',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return AnimatedContainer(
      duration: AppConstants.fadeInDuration,
      color: widget.isSelected
          ? AppColors.primary.withOpacity(0.3)
          : Colors.transparent,
      child: widget.isSelected
          ? Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.surface,
                  size: AppDimensions.iconSizeMedium,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTypeIndicator() {
    if (widget.item.isGif) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSmall,
          vertical: AppDimensions.paddingSmall / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gif,
              color: AppColors.surface,
              size: AppDimensions.iconSizeSmall,
            ),
            SizedBox(width: 2),
            Text(
              'GIF',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildDateLabel() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDate(widget.item.timestamp),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.item.isGif)
            Icon(
              Icons.play_circle_filled,
              color: AppColors.surface,
              size: AppDimensions.iconSizeSmall,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '今';
    }
  }
}

// ギャラリーアイテムの詳細ビュー
class GalleryItemDetailView extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const GalleryItemDetailView({
    Key? key,
    required this.item,
    this.onEdit,
    this.onShare,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dotBackground,
      appBar: AppBar(
        backgroundColor: AppColors.dotBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.surface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item.fileName,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
        ),
        actions: [
          if (onShare != null)
            IconButton(
              icon: Icon(Icons.share, color: AppColors.surface),
              onPressed: onShare,
            ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.surface),
              onPressed: onDelete,
            ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: item.filePath,
          child: FutureBuilder<Uint8List>(
            future: item.getBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Icon(
                  Icons.broken_image,
                  color: AppColors.surface,
                  size: 64,
                );
              }

              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: Image.memory(snapshot.data!, fit: BoxFit.contain),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ファイル情報
            _buildFileInfo(),

            SizedBox(height: AppDimensions.paddingMedium),

            // アクションボタン
            Row(
              children: [
                if (onEdit != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit),
                      label: Text('編集'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingSmall),
                ],
                if (onShare != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onShare,
                      icon: Icon(Icons.share),
                      label: Text('シェア'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.surface,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingSmall),
                ],
                if (onDelete != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete),
                      label: Text('削除'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.surface,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ファイル情報',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppDimensions.paddingSmall),
        _buildInfoRow('ファイル名', item.fileName),
        _buildInfoRow('タイプ', item.isGif ? 'GIF' : '画像'),
        _buildInfoRow('作成日時', _formatFullDate(item.timestamp)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingSmall / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

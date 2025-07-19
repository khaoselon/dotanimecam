import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

// ギャラリーフィルターバー
class GalleryFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Map<String, int> itemCounts;

  const GalleryFilterBar({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.itemCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildFilterTab(
            'all',
            'すべて',
            itemCounts['all'] ?? 0,
            selectedFilter == 'all',
            onFilterChanged,
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          _buildFilterTab(
            'images',
            '画像',
            itemCounts['images'] ?? 0,
            selectedFilter == 'images',
            onFilterChanged,
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          _buildFilterTab(
            'gifs',
            'GIF',
            itemCounts['gifs'] ?? 0,
            selectedFilter == 'gifs',
            onFilterChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    String filter,
    String label,
    int count,
    bool isSelected,
    Function(String) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(filter),
      child: AnimatedContainer(
        duration: AppConstants.fadeInDuration,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            SizedBox(width: AppDimensions.paddingSmall / 2),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall / 2,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surface.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                count.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.surface : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

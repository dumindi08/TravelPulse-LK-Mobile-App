import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// TravelPulse LK — Crowd Density Visual Meter Badge
class CrowdMeterBadge extends StatelessWidget {
  final String crowdLevel;
  final bool showLabel;
  final bool isDetailed;

  const CrowdMeterBadge({
    super.key,
    required this.crowdLevel,
    this.showLabel = true,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = _resolveCrowdInfo(crowdLevel);

    if (isDetailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: info.backgroundColor,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: info.color.withOpacity(0.3), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, size: 20, color: info.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: info.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildBars(info.activeBars, info.color),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: info.backgroundColor,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: info.color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: info.color),
          if (showLabel) ...[
            const SizedBox(width: 5),
            Text(
              info.title,
              style: AppTypography.labelSmall.copyWith(
                color: info.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBars(int activeBars, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < activeBars;
        return Container(
          width: 5,
          height: 14 + (index * 4.0),
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: isActive ? color : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  _CrowdInfo _resolveCrowdInfo(String level) {
    final lower = level.toLowerCase().trim();

    if (lower == 'empty' || lower == 'low') {
      return const _CrowdInfo(
        title: 'Light Crowd',
        description: 'Seats readily available',
        icon: Icons.airline_seat_recline_normal_rounded,
        color: AppColors.crowdEmpty,
        backgroundColor: AppColors.successLight,
        activeBars: 1,
      );
    } else if (lower == 'moderate' || lower == 'medium') {
      return const _CrowdInfo(
        title: 'Moderate Crowd',
        description: 'Few seats available, comfortable standing',
        icon: Icons.groups_rounded,
        color: AppColors.crowdModerate,
        backgroundColor: AppColors.infoLight,
        activeBars: 2,
      );
    } else if (lower == 'crowded' || lower == 'heavy') {
      return const _CrowdInfo(
        title: 'Heavy Crowd',
        description: 'Standing room only, tight boarding',
        icon: Icons.group_add_rounded,
        color: AppColors.crowdCrowded,
        backgroundColor: AppColors.warningLight,
        activeBars: 3,
      );
    } else {
      // packed / very_crowded
      return const _CrowdInfo(
        title: 'Overcrowded',
        description: 'Packed vehicle, difficult to board',
        icon: Icons.warning_amber_rounded,
        color: AppColors.crowdPacked,
        backgroundColor: AppColors.errorLight,
        activeBars: 4,
      );
    }
  }
}

class _CrowdInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final int activeBars;

  const _CrowdInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.activeBars,
  });
}


import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/travel_alert_model.dart';

/// TravelPulse LK — Map Safety Advisory Banner (Thimaya)
/// Surfaces urgent road conditions and weather emergencies directly above the map.
class MapSafetyBanner extends StatelessWidget {
  final TravelAlertModel alert;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const MapSafetyBanner({
    super.key,
    required this.alert,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.isCritical;
    final bgColor = isCritical ? AppColors.errorLight : AppColors.warningLight;
    final borderColor = isCritical ? AppColors.error : AppColors.warning;
    final iconColor = isCritical ? AppColors.errorDark : AppColors.warningDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.roundedMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(alert.alertIcon, color: iconColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              alert.title,
                              style: AppTypography.titleSmall.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.15),
                              borderRadius: AppSpacing.roundedPill,
                            ),
                            child: Text(
                              alert.severity.toUpperCase(),
                              style: AppTypography.caption.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.message,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


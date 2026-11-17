import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum BadgeType { status, severity, operator }

/// TravelPulse LK — Semantic Status and Tag Badge
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final Color? customColor;
  final Color? customTextColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.status,
    this.customColor,
    this.customTextColor,
    this.icon,
  });

  factory StatusBadge.reportStatus(String status) {
    return StatusBadge(
      label: status,
      type: BadgeType.status,
    );
  }

  factory StatusBadge.severity(String severity) {
    return StatusBadge(
      label: severity,
      type: BadgeType.severity,
    );
  }

  factory StatusBadge.operator(String operatorName) {
    return StatusBadge(
      label: operatorName,
      type: BadgeType.operator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    final effectiveBg = customColor ?? colors.background;
    final effectiveText = customTextColor ?? colors.text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(
          color: colors.border ?? effectiveBg,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: effectiveText),
            const SizedBox(width: 4),
          ] else if (colors.dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            _formatLabel(label),
            style: AppTypography.labelSmall.copyWith(
              color: effectiveText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String text) {
    if (text.isEmpty) return '';
    final cleaned = text.replaceAll('_', ' ');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  _BadgeColors _resolveColors() {
    final lower = label.toLowerCase().trim();

    switch (type) {
      case BadgeType.status:
        if (lower == 'verified') {
          return const _BadgeColors(
            background: AppColors.successLight,
            text: AppColors.successDark,
            dotColor: AppColors.success,
          );
        } else if (lower == 'submitted' || lower == 'unverified') {
          return const _BadgeColors(
            background: AppColors.infoLight,
            text: AppColors.infoDark,
            dotColor: AppColors.info,
          );
        } else if (lower == 'plausible') {
          return const _BadgeColors(
            background: AppColors.warningLight,
            text: AppColors.warningDark,
            dotColor: AppColors.warning,
          );
        } else if (lower == 'disputed' || lower == 'rejected') {
          return const _BadgeColors(
            background: AppColors.errorLight,
            text: AppColors.errorDark,
            dotColor: AppColors.error,
          );
        } else if (lower == 'resolved') {
          return const _BadgeColors(
            background: AppColors.surfaceVariant,
            text: AppColors.textSecondary,
            dotColor: AppColors.textSecondary,
          );
        }
        break;

      case BadgeType.severity:
        if (lower == 'critical') {
          return const _BadgeColors(
            background: AppColors.errorLight,
            text: AppColors.errorDark,
            dotColor: AppColors.error,
          );
        } else if (lower == 'warning' || lower == 'high') {
          return const _BadgeColors(
            background: AppColors.warningLight,
            text: AppColors.warningDark,
            dotColor: AppColors.warning,
          );
        } else if (lower == 'info' || lower == 'low' || lower == 'medium') {
          return const _BadgeColors(
            background: AppColors.infoLight,
            text: AppColors.infoDark,
            dotColor: AppColors.info,
          );
        }
        break;

      case BadgeType.operator:
        if (lower.contains('sltb')) {
          return const _BadgeColors(
            background: Color(0xFFFEE2E2),
            text: AppColors.operatorSltb,
            dotColor: AppColors.operatorSltb,
          );
        } else if (lower.contains('private')) {
          return const _BadgeColors(
            background: Color(0xFFE0F2FE),
            text: AppColors.operatorPrivate,
            dotColor: AppColors.operatorPrivate,
          );
        } else if (lower.contains('railway') || lower.contains('train')) {
          return const _BadgeColors(
            background: Color(0xFFD1FAE5),
            text: AppColors.operatorTrain,
            dotColor: AppColors.operatorTrain,
          );
        }
        break;
    }

    return const _BadgeColors(
      background: AppColors.surfaceVariant,
      text: AppColors.textSecondary,
      dotColor: AppColors.textSecondary,
    );
  }
}

class _BadgeColors {
  final Color background;
  final Color text;
  final Color? dotColor;
  final Color? border;

  const _BadgeColors({
    required this.background,
    required this.text,
    this.dotColor,
    this.border,
  });
}


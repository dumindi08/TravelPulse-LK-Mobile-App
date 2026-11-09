import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/user_reputation_model.dart';

/// TravelPulse LK — Commuter Reputation & Trust Badge Card (Suneth)
/// Visualizes Table 12 (`user_reputations`) metrics and contributor standing.
class ReputationBadgeCard extends StatelessWidget {
  final UserReputationModel reputation;
  final VoidCallback? onTap;

  const ReputationBadgeCard({
    super.key,
    required this.reputation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Commuter Credibility', style: AppTypography.titleSmall),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: reputation.tierColor.withOpacity(0.12),
                            borderRadius: AppSpacing.roundedPill,
                          ),
                          child: Text(
                            reputation.trustTier.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: reputation.tierColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Algorithmic Reliability Engine (Suneth)',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reputation.reputationScore.toStringAsFixed(1)}/100',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('Trust Score', style: AppTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Visual Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (reputation.reputationScore / 100.0).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(reputation.tierColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Stat Grid
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  icon: Icons.assignment_turned_in_outlined,
                  value: '${reputation.verifiedReportsCount}/${reputation.totalReportsSubmitted}',
                  label: 'Verified Reports',
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(
                child: _buildMetric(
                  icon: Icons.how_to_vote_outlined,
                  value: '${reputation.totalVotesCast}',
                  label: 'Votes Cast',
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.border),
              Expanded(
                child: _buildMetric(
                  icon: Icons.percent_rounded,
                  value: '${reputation.accuracyRate.toStringAsFixed(0)}%',
                  label: 'Accuracy Rate',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


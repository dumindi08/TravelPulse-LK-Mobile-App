import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// TravelPulse LK — Peer Verification Voting Bar (Suneth)
/// Interactive widget allowing commuters to upvote (confirm) or downvote (dispute)
/// a community report, updating algorithmic reliability scores in real time.
class ReportVotingBar extends StatelessWidget {
  final int reportId;
  final int upvotesCount;
  final int downvotesCount;
  final double reliabilityScore;
  final String confidenceStatus;
  final String? userVote; // 'upvote', 'downvote', or null
  final bool isAuthor;
  final Function(String voteType) onVote;

  const ReportVotingBar({
    super.key,
    required this.reportId,
    required this.upvotesCount,
    required this.downvotesCount,
    required this.reliabilityScore,
    required this.confidenceStatus,
    this.userVote,
    this.isAuthor = false,
    required this.onVote,
  });

  Color _resolveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'plausible':
        return AppColors.info;
      case 'disputed':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveStatusColor(confidenceStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Reliability Score & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    'Reliability: ${reliabilityScore.toStringAsFixed(0)}%',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: AppSpacing.roundedPill,
                ),
                child: Text(
                  confidenceStatus.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bottom Row: Action Buttons
          Row(
            children: [
              // Upvote Button
              Expanded(
                child: InkWell(
                  onTap: isAuthor ? null : () => onVote('upvote'),
                  borderRadius: AppSpacing.roundedSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: userVote == 'upvote'
                          ? AppColors.successLight
                          : AppColors.surface,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(
                        color: userVote == 'upvote' ? AppColors.success : AppColors.border,
                        width: userVote == 'upvote' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 14,
                          color: userVote == 'upvote' ? AppColors.successDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Confirm ($upvotesCount)',
                          style: AppTypography.caption.copyWith(
                            color: userVote == 'upvote' ? AppColors.successDark : AppColors.textPrimary,
                            fontWeight: userVote == 'upvote' ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Downvote Button
              Expanded(
                child: InkWell(
                  onTap: isAuthor ? null : () => onVote('downvote'),
                  borderRadius: AppSpacing.roundedSm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: userVote == 'downvote'
                          ? AppColors.errorLight
                          : AppColors.surface,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(
                        color: userVote == 'downvote' ? AppColors.error : AppColors.border,
                        width: userVote == 'downvote' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_down_alt_rounded,
                          size: 14,
                          color: userVote == 'downvote' ? AppColors.errorDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dispute ($downvotesCount)',
                          style: AppTypography.caption.copyWith(
                            color: userVote == 'downvote' ? AppColors.errorDark : AppColors.textPrimary,
                            fontWeight: userVote == 'downvote' ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (isAuthor) ...[
            const SizedBox(height: 4),
            Text(
              'Authors cannot vote on their own community reports.',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


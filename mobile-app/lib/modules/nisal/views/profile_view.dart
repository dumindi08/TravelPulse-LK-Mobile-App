import 'package:flutter/material.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../providers/auth_provider.dart';
import '../../dumindi/providers/report_provider.dart';
import '../../dumindi/views/my_reports_view.dart';
import '../../dumindi/views/recent_reports_view.dart';
import '../../suneth/providers/crowd_provider.dart';
import '../../suneth/models/user_reputation_model.dart';
import '../../suneth/widgets/reputation_badge_card.dart';

/// TravelPulse LK — Profile & Account Management Screen (Nisal)
/// Handles commuter profile inspection, role badge, session status, and logout.
class ProfileView extends StatelessWidget {
  final AuthProvider authProvider;
  final ReportProvider? reportProvider;
  final CrowdProvider? crowdProvider;

  const ProfileView({
    super.key,
    required this.authProvider,
    this.reportProvider,
    this.crowdProvider,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your TravelPulse account?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConstants.welcome,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser;
    final isGuest = authProvider.isGuest;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Account & Profile',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isGuest ? AppColors.surfaceVariant : AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isGuest ? AppColors.borderDark : AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                        size: 32,
                        color: isGuest ? AppColors.textSecondary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isGuest ? 'Guest Commuter' : (user?.name ?? 'Commuter'),
                                  style: AppTypography.headlineMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isGuest && user != null) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.isModerator
                                        ? AppColors.warningLight
                                        : AppColors.primaryLight,
                                    borderRadius: AppSpacing.roundedPill,
                                  ),
                                  child: Text(
                                    user.role.toUpperCase(),
                                    style: AppTypography.overline.copyWith(
                                      color: user.isModerator
                                          ? AppColors.warningDark
                                          : AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGuest ? 'Browsing transit network in guest mode' : (user?.email ?? ''),
                            style: AppTypography.bodySmall,
                          ),
                          if (!isGuest && user?.phoneNumber != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user!.phoneNumber!,
                              style: AppTypography.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Account Status & Trust Banner
              if (isGuest) ...[
                AppCard(
                  color: AppColors.primaryContainer,
                  borderColor: AppColors.primary.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Limited Guest Session',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'You are currently exploring as a guest. Create an account or sign in to submit community reports, vote on transit disruptions, and save favorite routes.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        text: 'Sign In / Create Account',
                        onPressed: () {
                          Navigator.of(context).pushNamed(RouteConstants.signIn);
                        },
                        height: 40,
                        variant: AppButtonVariant.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Commuter Credibility & Trust Card (Suneth Engine)
              if (!isGuest && user != null) ...[
                ReputationBadgeCard(
                  reputation: crowdProvider?.userReputation ??
                      UserReputationModel(
                        userId: user.id,
                        reputationScore: user.isModerator ? 98.0 : 82.5,
                        totalReportsSubmitted: user.isModerator ? 20 : 6,
                        verifiedReportsCount: user.isModerator ? 19 : 5,
                        rejectedReportsCount: 0,
                        totalVotesCast: user.isModerator ? 45 : 14,
                        updatedAt: DateTime.now(),
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Community Contributions Section
              Text('Community Contributions', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.assignment_outlined, color: AppColors.primary),
                      title: Text('My Submitted Reports', style: AppTypography.bodyLarge),
                      subtitle: const Text('View and manage your incident reports', style: AppTypography.caption),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MyReportsView(
                              authProvider: authProvider,
                              reportProvider: reportProvider ?? ReportProvider(),
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dynamic_feed_rounded, color: AppColors.primary),
                      title: Text('Community Reports Feed', style: AppTypography.bodyLarge),
                      subtitle: const Text('Browse verified reports across the island', style: AppTypography.caption),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecentReportsView(
                              authProvider: authProvider,
                              reportProvider: reportProvider ?? ReportProvider(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Commuter Preferences Section
              Text('Transit Preferences', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_outlined, color: AppColors.primary),
                      title: Text('Frequent Home Stop', style: AppTypography.bodyLarge),
                      subtitle: Text(
                        user?.profile?.homeStopName ?? 'Pettah Main Bus Stand',
                        style: AppTypography.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.work_outline_rounded, color: AppColors.primary),
                      title: Text('Work / Destination Stop', style: AppTypography.bodyLarge),
                      subtitle: Text(
                        user?.profile?.workStopName ?? 'Bambalapitiya Junction',
                        style: AppTypography.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.directions_bus_outlined, color: AppColors.primary),
                      title: Text('Preferred Transport Mode', style: AppTypography.bodyLarge),
                      subtitle: Text(
                        (user?.profile?.preferredTransportMode ?? 'any').toUpperCase(),
                        style: AppTypography.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // App Information
              Text('Application Information', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                      title: Text('TravelPulse LK Version', style: AppTypography.bodyLarge),
                      subtitle: Text('v1.0.0 (SE5104 Group 10)', style: AppTypography.caption),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined, color: AppColors.textSecondary),
                      title: Text('Data Privacy & Terms', style: AppTypography.bodyLarge),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textMuted),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy: Commuter reports mask personal identity on public feeds.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Sign Out Button
              AppButton(
                text: isGuest ? 'Exit Guest Session' : 'Sign Out',
                onPressed: () => _handleLogout(context),
                leadingIcon: Icons.logout_rounded,
                variant: AppButtonVariant.outlined,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}


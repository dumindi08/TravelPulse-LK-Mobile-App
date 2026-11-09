import 'package:flutter/material.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

/// TravelPulse LK — Welcome & Onboarding Screen (Nisal)
/// Entry point for new users, returning commuters, and guest access.
class WelcomeView extends StatefulWidget {
  final AuthProvider authProvider;

  const WelcomeView({
    super.key,
    required this.authProvider,
  });

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _slides = const [
    _OnboardingItem(
      title: 'Smart Transit Tracking',
      subtitle: 'Find bus and train routes, real-time stop sequences, and schedules across Sri Lanka.',
      icon: Icons.directions_bus_rounded,
      badge: 'Public Transport',
    ),
    _OnboardingItem(
      title: 'Community Incident Alerts',
      subtitle: 'Report breakdowns, road floods, and traffic jams. Get verified updates from fellow commuters.',
      icon: Icons.campaign_rounded,
      badge: 'Live Reports',
    ),
    _OnboardingItem(
      title: 'Crowd Intelligence',
      subtitle: 'Know how crowded your bus or train station is before you travel with real-time crowd meters.',
      icon: Icons.groups_rounded,
      badge: 'Crowd Insights',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGuestContinue() {
    widget.authProvider.continueAsGuest();
    Navigator.of(context).pushReplacementNamed(RouteConstants.mainShell);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Brand Logo & Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppSpacing.roundedMd,
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: AppColors.textInverse,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  const Text(
                    'TravelPulse LK',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Sri Lanka’s Community Transit Network',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),

              // Feature Carousel
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Icon(
                                    slide.icon,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: AppSpacing.roundedPill,
                                  ),
                                  child: Text(
                                    slide.badge,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  slide.title,
                                  style: AppTypography.headlineLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  slide.subtitle,
                                  style: AppTypography.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Carousel Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isSelected = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.borderDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteConstants.signUp);
                    },
                    variant: AppButtonVariant.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Sign In',
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteConstants.signIn);
                    },
                    variant: AppButtonVariant.outlined,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _onGuestContinue,
                    child: Text(
                      'Continue as Guest',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;

  const _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
  });
}

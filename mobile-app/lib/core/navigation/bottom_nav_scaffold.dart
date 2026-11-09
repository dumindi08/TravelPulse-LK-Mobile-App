import 'package:flutter/material.dart';
import '../constants/route_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../../modules/nisal/providers/auth_provider.dart';
import '../../modules/nisal/views/profile_view.dart';

/// TravelPulse LK — Primary Navigation Shell
/// Implements persistent 5-item bottom navigation matching the Figma layout.
/// Features a dedicated center Report action adhering to the single-report requirement.
class BottomNavScaffold extends StatefulWidget {
  final AuthProvider authProvider;
  final int initialIndex;

  const BottomNavScaffold({
    super.key,
    required this.authProvider,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Index 2 is the dedicated center "Report" action
      _handleReportAction();
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _handleReportAction() {
    if (widget.authProvider.isGuest) {
      _showGuestReportPrompt();
      return;
    }

    // Modal action sheet for Report creation flow (Scheduled for Stage 4 implementation)
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Community Reporting', style: AppTypography.headlineMedium),
                        const SizedBox(height: 2),
                        Text('Dumindi’s Disruption & Incident Module', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'The dedicated Report action connects directly to the Create Report workflow (Crowd Report, Road Condition, Transport Tracking, Service Disruption with specific reason, Accident/Incident).',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_outlined, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Full 6-category submission form scheduled for Stage 4.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Understood'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuestReportPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
        title: Row(
          children: [
            const Icon(Icons.account_circle_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            const Text('Sign In Required'),
          ],
        ),
        content: Text(
          'Anonymous and identified community reports require an active user session to track report ownership and maintain community trust.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(RouteConstants.signIn);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  int _resolveStackIndex(int bottomNavIndex) {
    switch (bottomNavIndex) {
      case 0:
        return 0; // Home
      case 1:
        return 1; // Routes
      case 3:
        return 2; // Map & Alerts
      case 4:
        return 3; // Profile
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authProvider.currentUser;
    final isGuest = widget.authProvider.isGuest;

    final stackIndex = _resolveStackIndex(_currentIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: stackIndex,
        children: [
          // 0. Home Tab Shell
          _HomeTabShell(
            commuterName: isGuest ? 'Guest' : (user?.name ?? 'Commuter'),
            isGuest: isGuest,
            onSearchTapped: () => setState(() => _currentIndex = 1),
            onMapTapped: () => setState(() => _currentIndex = 3),
            onReportTapped: _handleReportAction,
          ),

          // 1. Routes Tab Shell
          const _RoutesTabShell(),

          // 2. Map & Alerts Tab Shell
          const _MapTabShell(),

          // 3. Profile Tab View
          ProfileView(authProvider: widget.authProvider),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.labelSmall,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus_rounded),
              label: 'Routes',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.textInverse,
                  size: 22,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.textInverse,
                  size: 22,
                ),
              ),
              label: 'Report',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Stage 2 Tab Shells (Structured containers connecting navigation)
// -----------------------------------------------------------------------------

class _HomeTabShell extends StatelessWidget {
  final String commuterName;
  final bool isGuest;
  final VoidCallback onSearchTapped;
  final VoidCallback onMapTapped;
  final VoidCallback onReportTapped;

  const _HomeTabShell({
    required this.commuterName,
    required this.isGuest,
    required this.onSearchTapped,
    required this.onMapTapped,
    required this.onReportTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $commuterName 👋',
                      style: AppTypography.headlineLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGuest ? 'Exploring transit routes' : 'Ready for your journey today?',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppSpacing.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live Network',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick Navigation Action Cards
            Text('Quick Transit Actions', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Search Routes',
                    subtitle: 'Find bus & trains',
                    icon: Icons.search_rounded,
                    color: AppColors.primary,
                    onTap: onSearchTapped,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionCard(
                    title: 'Live Map',
                    subtitle: 'Road hazards',
                    icon: Icons.map_rounded,
                    color: AppColors.secondary,
                    onTap: onMapTapped,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Create Report',
                    subtitle: 'Report delays',
                    icon: Icons.campaign_rounded,
                    color: AppColors.warningDark,
                    onTap: onReportTapped,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ActionCard(
                    title: 'Crowd Status',
                    subtitle: 'Bus congestion',
                    icon: Icons.groups_rounded,
                    color: AppColors.primaryDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Crowd Intelligence engine scheduled for Stage 5.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stage Status Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Stage 2: Navigation & Auth Active', style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Authentication session, guest access, persistent 5-tab shell, and verified theme tokens are successfully integrated.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Upcoming Module Roadmap:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('• Stage 3: Journey & Route Management (Nisal)', style: AppTypography.caption),
                  Text('• Stage 4: Community Reporting Pipeline (Dumindi)', style: AppTypography.caption),
                  Text('• Stage 5: Crowd Intelligence & Reliability Engine (Suneth)', style: AppTypography.caption),
                  Text('• Stage 6: Maps, Road Conditions & Alerts (Thimaya)', style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutesTabShell extends StatelessWidget {
  const _RoutesTabShell();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus_rounded, size: 54, color: AppColors.primary),
                SizedBox(height: 16),
                Text('Routes & Schedules Explorer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                SizedBox(height: 8),
                Text('Scheduled for implementation in Stage 3 (Nisal’s Module).', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapTabShell extends StatelessWidget {
  const _MapTabShell();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 54, color: AppColors.secondary),
                SizedBox(height: 16),
                Text('Live Maps & Road Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                SizedBox(height: 8),
                Text('Scheduled for implementation in Stage 6 (Thimaya’s Module).', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: AppSpacing.roundedSm,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTypography.titleSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}


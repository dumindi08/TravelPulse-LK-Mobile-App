import 'package:flutter/material.dart';
import '../constants/route_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../../modules/nisal/providers/auth_provider.dart';
import '../../modules/nisal/providers/route_provider.dart';
import '../../modules/nisal/providers/journey_provider.dart';
import '../../modules/dumindi/providers/report_provider.dart';
import '../../modules/dumindi/views/create_report_view.dart';
import '../../modules/nisal/views/home_view.dart';
import '../../modules/nisal/views/route_search_view.dart';
import '../../modules/nisal/views/profile_view.dart';

/// TravelPulse LK — Primary Navigation Shell
/// Implements persistent 5-item bottom navigation matching the Figma layout.
/// Features a dedicated center Report action adhering to the single-report requirement.
class BottomNavScaffold extends StatefulWidget {
  final AuthProvider authProvider;
  final RouteProvider? routeProvider;
  final JourneyProvider? journeyProvider;
  final ReportProvider? reportProvider;
  final int initialIndex;

  const BottomNavScaffold({
    super.key,
    required this.authProvider,
    this.routeProvider,
    this.journeyProvider,
    this.reportProvider,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late int _currentIndex;
  late final RouteProvider _routeProvider;
  late final JourneyProvider _journeyProvider;
  late final ReportProvider _reportProvider;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _routeProvider = widget.routeProvider ?? RouteProvider();
    _journeyProvider = widget.journeyProvider ?? JourneyProvider();
    _reportProvider = widget.reportProvider ?? ReportProvider();
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

    // Opens Community Report creation workflow
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportView(
          authProvider: widget.authProvider,
          reportProvider: _reportProvider,
          routeProvider: _routeProvider,
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
    final stackIndex = _resolveStackIndex(_currentIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: stackIndex,
        children: [
          // 0. Home Screen (Nisal)
          HomeView(
            authProvider: widget.authProvider,
            routeProvider: _routeProvider,
            journeyProvider: _journeyProvider,
            reportProvider: _reportProvider,
            onSearchTapped: () => setState(() => _currentIndex = 1),
            onMapTapped: () => setState(() => _currentIndex = 3),
            onReportTapped: _handleReportAction,
          ),

          // 1. Routes & Schedules Explorer (Nisal)
          RouteSearchView(
            routeProvider: _routeProvider,
            journeyProvider: _journeyProvider,
            authProvider: widget.authProvider,
          ),

          // 2. Map & Alerts Tab Shell (Thimaya — Stage 6)
          const _MapTabShell(),

          // 3. Profile Tab View (Nisal)
          ProfileView(
            authProvider: widget.authProvider,
            reportProvider: _reportProvider,
          ),
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
                Text(
                  'Live Maps & Road Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'Scheduled for implementation in Stage 6 (Thimaya’s Module).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/crowd_meter_badge.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/route_model.dart';
import '../models/journey_model.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/journey_provider.dart';
import '../../dumindi/providers/report_provider.dart';
import '../../dumindi/views/recent_reports_view.dart';
import 'route_details_view.dart';

/// TravelPulse LK — Home Screen (Nisal)
/// The central commuter hub featuring live transit updates, rapid route search,
/// active journey monitoring, and popular Sri Lankan transport corridors.
class HomeView extends StatelessWidget {
  final AuthProvider authProvider;
  final RouteProvider routeProvider;
  final JourneyProvider journeyProvider;
  final ReportProvider? reportProvider;
  final VoidCallback onSearchTapped;
  final VoidCallback onMapTapped;
  final VoidCallback onReportTapped;

  const HomeView({
    super.key,
    required this.authProvider,
    required this.routeProvider,
    required this.journeyProvider,
    this.reportProvider,
    required this.onSearchTapped,
    required this.onMapTapped,
    required this.onReportTapped,
  });

  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser;
    final isGuest = authProvider.isGuest;
    final commuterName = isGuest ? 'Guest Commuter' : (user?.name ?? 'Commuter');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await Future.wait([
              routeProvider.loadRoutes(),
              journeyProvider.loadJourneys(userId: user?.id),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Commuter Greeting Header
                _buildHeader(commuterName, isGuest),
                const SizedBox(height: AppSpacing.md),

                // 2. Interactive Transit Search Bar Shortcut
                _buildSearchBar(context),
                const SizedBox(height: AppSpacing.md),

                // 3. Live Transit Disruption Ticker
                _buildDisruptionTicker(context),
                const SizedBox(height: AppSpacing.lg),

                // 4. Quick Transit Action Cards (2x2 Grid)
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.lg),

                // 5. Active or Recent Journey Section
                _buildJourneySection(context),
                const SizedBox(height: AppSpacing.lg),

                // 6. Popular Transit Corridors (Routes List)
                _buildPopularRoutesHeader(context),
                const SizedBox(height: AppSpacing.sm),
                _buildPopularRoutesList(context),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String commuterName, bool isGuest) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hello, $commuterName',
                    style: AppTypography.headlineLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isGuest ? 'Browse routes & real-time schedules' : 'Where are you heading today?',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppSpacing.roundedPill,
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
              const SizedBox(width: 6),
              Text(
                'Live Network',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return InkWell(
      onTap: onSearchTapped,
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Search routes, stops (e.g. 138, Pettah, Kandy)...',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Filter', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisruptionTicker(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(RouteConstants.alerts);
      },
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.surface, size: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Transit Alerts (View Feed)',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.warningDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Colombo Metro',
                            style: AppTypography.caption.copyWith(color: AppColors.warningDark),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.warningDark),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Route 138: Traffic obstruction near Town Hall roundabout. Main Line train delays ~15 mins.',
                    style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Transit Actions', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                title: 'Search Routes',
                subtitle: 'Bus & Rail options',
                icon: Icons.directions_bus_rounded,
                color: AppColors.primary,
                onTap: onSearchTapped,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionTile(
                title: 'Live Map',
                subtitle: 'Road conditions',
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
              child: _ActionTile(
                title: 'Create Report',
                subtitle: 'Report delays',
                icon: Icons.campaign_rounded,
                color: AppColors.warningDark,
                onTap: onReportTapped,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionTile(
                title: 'Crowd Status',
                subtitle: 'Density indicators',
                icon: Icons.groups_rounded,
                color: const Color(0xFF4F46E5),
                onTap: () {
                  Navigator.of(context).pushNamed(RouteConstants.crowdStatus);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJourneySection(BuildContext context) {
    return ListenableBuilder(
      listenable: journeyProvider,
      builder: (context, _) {
        final active = journeyProvider.activeJourney;

        if (active != null) {
          return _buildActiveJourneyCard(context, active);
        }

        // If no active journey, show recent completed journey or plan trip prompt
        if (journeyProvider.journeys.isNotEmpty) {
          final last = journeyProvider.journeys.first;
          return _buildRecentJourneyCard(context, last);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActiveJourneyCard(BuildContext context, JourneyModel journey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.primary, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Journey In Progress',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                ),
                child: Text(
                  'Route ${journey.routeNumber}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(journey.routeName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'From: ${journey.originStopName}',
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'To: ${journey.destinationStopName}',
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  journeyProvider.cancelJourney(journey.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journey cancelled.')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  journeyProvider.completeJourney(journey.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journey completed! Thank you for traveling with TravelPulse LK.')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Complete Journey'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJourneyCard(BuildContext context, JourneyModel journey) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: const Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Journey', style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(
                  'Route ${journey.routeNumber} (${journey.originStopName} → ${journey.destinationStopName})',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onSearchTapped(),
            child: const Text('Plan Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRoutesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Popular Transit Routes', style: AppTypography.titleMedium),
            const SizedBox(height: 2),
            Text('Sri Lanka key transport arteries', style: AppTypography.caption),
          ],
        ),
        TextButton(
          onPressed: onSearchTapped,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('View All'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularRoutesList(BuildContext context) {
    return ListenableBuilder(
      listenable: routeProvider,
      builder: (context, _) {
        if (routeProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (routeProvider.routes.isEmpty) {
          return EmptyStateView(
            title: 'No Routes Available',
            message: 'Transit route data is currently offline.',
            icon: Icons.directions_bus_outlined,
            actionText: 'Refresh',
            onAction: () => routeProvider.loadRoutes(),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: routeProvider.routes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final route = routeProvider.routes[index];
            final isFav = routeProvider.isFavorite(route.id);

            return _RouteCard(
              route: route,
              isFavorite: isFav,
              onToggleFavorite: () => routeProvider.toggleFavorite(route.id),
              onTap: () {
                routeProvider.selectRoute(route.id);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RouteDetailsView(
                      routeId: route.id,
                      routeProvider: routeProvider,
                      journeyProvider: journeyProvider,
                      authProvider: authProvider,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteModel route;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _RouteCard({
    required this.route,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Route Badge + Operator + Favorite Star
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      route.isTrain ? Icons.train_rounded : Icons.directions_bus_rounded,
                      size: 14,
                      color: AppColors.textInverse,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      route.routeNumber,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (route.operator != null)
                StatusBadge.operator(route.operator!),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite ? AppColors.warning : AppColors.textMuted,
                  size: 22,
                ),
                onPressed: onToggleFavorite,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Route Name
          Text(route.name, style: AppTypography.titleSmall),
          const SizedBox(height: 4),

          // Route endpoints
          Row(
            children: [
              Text(
                '${route.originCity} ➔ ${route.destinationCity}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Disruption summary banner if affected
          if (route.hasDisruption) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warningDark),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      route.activeDisruptionSummary!,
                      style: AppTypography.caption.copyWith(color: AppColors.warningDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bottom stats: Estimated time, stops count, and crowd status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('~${route.estTotalMinutes} mins', style: AppTypography.caption),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${route.stops.length} stops', style: AppTypography.caption),
                ],
              ),
              CrowdMeterBadge(crowdLevel: route.currentCrowdLevel ?? 'moderate'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
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
              child: Icon(icon, color: color, size: 20),
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

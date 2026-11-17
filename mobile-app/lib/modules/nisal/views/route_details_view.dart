import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/crowd_meter_badge.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../models/schedule_model.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/journey_provider.dart';
import '../../suneth/providers/crowd_provider.dart';
import '../../suneth/widgets/submit_crowd_bottom_sheet.dart';

/// TravelPulse LK — Route Details Screen (Nisal)
/// Comprehensive route overview including ordered stop sequences,
/// timetable schedules, real-time crowd indicators, and journey tracking.
class RouteDetailsView extends StatefulWidget {
  final int routeId;
  final RouteProvider routeProvider;
  final JourneyProvider journeyProvider;
  final AuthProvider authProvider;
  final CrowdProvider? crowdProvider;

  const RouteDetailsView({
    super.key,
    required this.routeId,
    required this.routeProvider,
    required this.journeyProvider,
    required this.authProvider,
    this.crowdProvider,
  });

  @override
  State<RouteDetailsView> createState() => _RouteDetailsViewState();
}

class _RouteDetailsViewState extends State<RouteDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.routeProvider.selectRoute(widget.routeId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onStartJourney(RouteModel route) {
    if (route.stops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot start journey: Route stops are unavailable.')),
      );
      return;
    }

    RouteStopSequenceModel selectedOrigin = route.stops.first;
    RouteStopSequenceModel selectedDest = route.stops.last;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan Your Journey', style: AppTypography.headlineMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: Text(
                            'Route ${route.routeNumber}',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Select your boarding and destination stops along this transit line.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Origin stop selector
                    Text('Boarding Stop:', style: AppTypography.titleSmall),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RouteStopSequenceModel>(
                          value: selectedOrigin,
                          isExpanded: true,
                          items: route.stops.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text('${s.stopOrder}. ${s.stopName}', style: AppTypography.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => selectedOrigin = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Destination stop selector
                    Text('Destination Stop:', style: AppTypography.titleSmall),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RouteStopSequenceModel>(
                          value: selectedDest,
                          isExpanded: true,
                          items: route.stops.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text('${s.stopOrder}. ${s.stopName}', style: AppTypography.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => selectedDest = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Confirm button
                    AppButton(
                      text: 'Start Journey Now',
                      leadingIcon: Icons.navigation_rounded,
                      onPressed: () async {
                        Navigator.of(ctx).pop();

                        final userId = widget.authProvider.currentUser?.id ?? 1;
                        final success = await widget.journeyProvider.startJourney(
                          userId: userId,
                          route: route,
                          originStop: selectedOrigin,
                          destinationStop: selectedDest,
                        );

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Journey started on Route ${route.routeNumber}! Track updates from the Home screen.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.journeyProvider.errorMessage ?? 'Could not start journey.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.routeProvider,
      builder: (context, _) {
        final route = widget.routeProvider.selectedRoute;
        final isLoading = widget.routeProvider.isLoading;

        if (isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (route == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Route Details')),
            body: Center(
              child: EmptyStateView(
                title: 'Route Not Found',
                message: 'The requested route could not be loaded.',
                icon: Icons.error_outline_rounded,
                actionText: 'Go Back',
                onAction: () => Navigator.of(context).pop(),
              ),
            ),
          );
        }

        final isFav = widget.routeProvider.isFavorite(route.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Route ${route.routeNumber}'),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFav ? AppColors.warning : AppColors.textPrimary,
                  size: 24,
                ),
                tooltip: 'Toggle Favorite',
                onPressed: () => widget.routeProvider.toggleFavorite(route.id),
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Persistent Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildRouteHeaderCard(route),
                    if (route.hasDisruption) ...[
                      const SizedBox(height: 8),
                      _buildDisruptionBanner(route.activeDisruptionSummary!),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CrowdMeterBadge(
                            crowdLevel: widget.crowdProvider?.getCrowdLevelForRoute(route.id) ??
                                route.currentCrowdLevel ??
                                'moderate',
                            isDetailed: true,
                          ),
                        ),
                        if (widget.crowdProvider != null) ...[
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.add_reaction_outlined, color: AppColors.primary),
                            tooltip: 'Report Live Crowd',
                            onPressed: () {
                              final uid = widget.authProvider.currentUser?.id ?? 1;
                              SubmitCrowdBottomSheet.show(
                                context,
                                initialRouteId: route.id,
                                initialRouteNumber: route.routeNumber,
                                userId: uid,
                                crowdProvider: widget.crowdProvider!,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Tab Bar (Stops & Timetables)
              Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.alt_route_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text('Stops (${route.stops.length})'),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Timetable'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStopsTab(route),
                    _buildTimetableTab(route),
                  ],
                ),
              ),

              // Bottom Start Journey / In-Progress Action Bar
              _buildBottomActionBar(route),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteHeaderCard(RouteModel route) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      route.isTrain ? Icons.train_rounded : Icons.directions_bus_rounded,
                      size: 16,
                      color: AppColors.textInverse,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      route.routeNumber,
                      style: AppTypography.titleMedium.copyWith(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppSpacing.roundedPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('~${route.estTotalMinutes} mins', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(route.name, style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${route.originCity} ➔ ${route.destinationCity}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisruptionBanner(String summary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warningDark),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Transit Disruption',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warningDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(summary, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsTab(RouteModel route) {
    if (route.stops.isEmpty) {
      return const Center(child: Text('No stop sequences defined for this route.'));
    }

    double cumulativeKm = 0.0;
    int cumulativeMins = 0;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: route.stops.length,
      itemBuilder: (context, index) {
        final stop = route.stops[index];
        cumulativeKm += stop.distanceFromPrevKm;
        cumulativeMins += stop.estMinutesFromPrev;

        final isFirst = index == 0;
        final isLast = index == route.stops.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Column (Dots + Line)
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? AppColors.primary
                            : isLast
                                ? AppColors.error
                                : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFirst
                              ? AppColors.primary
                              : isLast
                                  ? AppColors.error
                                  : AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2.5,
                          color: AppColors.borderDark,
                        ),
                      ),
                  ],
                ),
              ),

              // Stop Details Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${stop.stopOrder}. ${stop.stopName}',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: (isFirst || isLast) ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isFirst)
                            StatusBadge(label: 'Origin', customColor: AppColors.primaryLight, customTextColor: AppColors.primary)
                          else if (isLast)
                            StatusBadge(label: 'Terminal', customColor: AppColors.errorLight, customTextColor: AppColors.errorDark),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (!isFirst) ...[
                            Text(
                              '+${stop.distanceFromPrevKm.toStringAsFixed(1)} km',
                              style: AppTypography.caption,
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                            Text(
                              '+${stop.estMinutesFromPrev} mins',
                              style: AppTypography.caption,
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                          ],
                          Text(
                            'Total ~${cumulativeMins} min (${cumulativeKm.toStringAsFixed(1)} km)',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimetableTab(RouteModel route) {
    return ListenableBuilder(
      listenable: widget.routeProvider,
      builder: (context, _) {
        final schedules = widget.routeProvider.schedules;
        final isSchedulesLoading = widget.routeProvider.isSchedulesLoading;

        return Column(
          children: [
            // Direction and Day Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surface,
              child: Column(
                children: [
                  // Direction selector: Outbound vs Inbound
                  Row(
                    children: [
                      Expanded(
                        child: _buildDirectionPill(
                          'Outbound (${route.originCity})',
                          'outbound',
                          widget.routeProvider.selectedScheduleDirection == 'outbound',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDirectionPill(
                          'Inbound (${route.destinationCity})',
                          'inbound',
                          widget.routeProvider.selectedScheduleDirection == 'inbound',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Day of week chips
                  Row(
                    children: [
                      _buildDayChip('All Days', 'all'),
                      const SizedBox(width: 6),
                      _buildDayChip('Weekdays', 'weekday'),
                      const SizedBox(width: 6),
                      _buildDayChip('Weekends', 'weekend'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Timetable list
            Expanded(
              child: isSchedulesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : schedules.isEmpty
                      ? const Center(
                          child: Text(
                            'No scheduled departures found for selected filters.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: schedules.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final s = schedules[index];
                            return _buildScheduleCard(s);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDirectionPill(String label, String direction, bool isSelected) {
    return InkWell(
      onTap: () => widget.routeProvider.setScheduleDirection(direction),
      borderRadius: AppSpacing.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppSpacing.roundedSm,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, String day) {
    final isSelected = widget.routeProvider.selectedScheduleDay == day;

    return InkWell(
      onTap: () => widget.routeProvider.setScheduleDay(day),
      borderRadius: AppSpacing.roundedPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: AppSpacing.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(RouteScheduleModel schedule) {
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
              color: AppColors.primaryLight,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: const Icon(Icons.departure_board_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      schedule.departureTime,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      schedule.arrivalTime,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.tripDirection.toUpperCase()} • ${schedule.dayOfWeek.toUpperCase()}${schedule.vehiclePlate != null ? " • ${schedule.vehiclePlate}" : ""}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppSpacing.roundedPill,
            ),
            child: Text(
              'Scheduled',
              style: AppTypography.labelSmall.copyWith(color: AppColors.successDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(RouteModel route) {
    return ListenableBuilder(
      listenable: widget.journeyProvider,
      builder: (context, _) {
        final activeJourney = widget.journeyProvider.activeJourney;
        final isThisRouteActive = activeJourney != null && activeJourney.routeId == route.id;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: isThisRouteActive
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                  'Journey In Progress',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${activeJourney.originStopName} ➔ ${activeJourney.destinationStopName}',
                              style: AppTypography.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.journeyProvider.completeJourney(activeJourney.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Journey completed!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.textInverse,
                        ),
                        child: const Text('Complete Trip'),
                      ),
                    ],
                  )
                : AppButton(
                    text: 'Start Journey on Route ${route.routeNumber}',
                    leadingIcon: Icons.navigation_rounded,
                    onPressed: () => _onStartJourney(route),
                  ),
          ),
        );
      },
    );
  }
}


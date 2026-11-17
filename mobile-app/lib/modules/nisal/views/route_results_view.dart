import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/crowd_meter_badge.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/route_model.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/journey_provider.dart';
import 'route_details_view.dart';

/// TravelPulse LK — Route Search Results Screen (Nisal)
/// Displays routes connecting specific origin and destination pairs,
/// with transit mode filtering, trip duration sorting, and crowd status.
class RouteResultsView extends StatefulWidget {
  final String origin;
  final String destination;
  final RouteProvider routeProvider;
  final JourneyProvider journeyProvider;
  final AuthProvider authProvider;

  const RouteResultsView({
    super.key,
    required this.origin,
    required this.destination,
    required this.routeProvider,
    required this.journeyProvider,
    required this.authProvider,
  });

  @override
  State<RouteResultsView> createState() => _RouteResultsViewState();
}

class _RouteResultsViewState extends State<RouteResultsView> {
  String _sortBy = 'fastest'; // 'fastest', 'crowd'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.routeProvider,
          builder: (context, _) {
            if (widget.routeProvider.isSearching) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            var list = List<RouteModel>.from(widget.routeProvider.searchResults);

            // Apply sorting
            if (_sortBy == 'fastest') {
              list.sort((a, b) => a.estTotalMinutes.compareTo(b.estTotalMinutes));
            } else if (_sortBy == 'crowd') {
              // Priority: empty > moderate > crowded > very_crowded
              final scoreMap = {'empty': 1, 'low': 1, 'moderate': 2, 'medium': 2, 'crowded': 3, 'heavy': 3, 'very_crowded': 4, 'packed': 4};
              list.sort((a, b) {
                final sa = scoreMap[a.currentCrowdLevel?.toLowerCase()] ?? 2;
                final sb = scoreMap[b.currentCrowdLevel?.toLowerCase()] ?? 2;
                return sa.compareTo(sb);
              });
            }

            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Search Query Summary Banner
                  _buildQuerySummary(list.length),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Filter & Sort Controls
                  _buildFilterAndSortRow(),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Results List or Empty State
                  if (list.isEmpty)
                    EmptyStateView(
                      title: 'No Transit Routes Found',
                      message: 'No direct or intermediate lines found between "${widget.origin}" and "${widget.destination}".',
                      icon: Icons.alt_route_rounded,
                      actionText: 'Modify Search',
                      onAction: () => Navigator.of(context).pop(),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final route = list[index];
                        final isFav = widget.routeProvider.isFavorite(route.id);

                        return _buildResultCard(route, isFav);
                      },
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuerySummary(int resultCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.trip_origin_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.origin.isEmpty ? 'Any Origin' : widget.origin,
                        style: AppTypography.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondary),
                    ),
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.destination.isEmpty ? 'Any Destination' : widget.destination,
                        style: AppTypography.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$resultCount transit ${resultCount == 1 ? "route" : "routes"} found',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Change',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortRow() {
    return Row(
      children: [
        // Mode filter pills
        _buildModeButton('All', 'all'),
        const SizedBox(width: 6),
        _buildModeButton('Bus', 'bus'),
        const SizedBox(width: 6),
        _buildModeButton('Train', 'train'),
        const Spacer(),

        // Sort toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.roundedSm,
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortBy,
              isDense: true,
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              icon: const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
              items: const [
                DropdownMenuItem(value: 'fastest', child: Text('Fastest Trip')),
                DropdownMenuItem(value: 'crowd', child: Text('Least Crowded')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _sortBy = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, String mode) {
    final isSelected = widget.routeProvider.selectedTransportType == mode;

    return InkWell(
      onTap: () => widget.routeProvider.setTransportTypeFilter(mode),
      borderRadius: AppSpacing.roundedPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppSpacing.roundedPill,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(RouteModel route, bool isFavorite) {
    return AppCard(
      onTap: () {
        widget.routeProvider.selectRoute(route.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RouteDetailsView(
              routeId: route.id,
              routeProvider: widget.routeProvider,
              journeyProvider: widget.journeyProvider,
              authProvider: widget.authProvider,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    const SizedBox(width: 4),
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
                onPressed: () => widget.routeProvider.toggleFavorite(route.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(route.name, style: AppTypography.titleSmall),
          const SizedBox(height: 3),
          Text(
            '${route.originCity} ➔ ${route.destinationCity}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (route.hasDisruption) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
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


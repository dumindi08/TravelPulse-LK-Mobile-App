import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/crowd_meter_badge.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../nisal/providers/auth_provider.dart';
import '../../nisal/providers/route_provider.dart';
import '../models/crowd_estimate_model.dart';
import '../providers/crowd_provider.dart';
import '../widgets/submit_crowd_bottom_sheet.dart';

/// TravelPulse LK — Transit Crowd Intelligence Overview Screen (Suneth)
/// Displays aggregated crowd density metrics across routes and transit hubs.
class CrowdStatusView extends StatefulWidget {
  final CrowdProvider crowdProvider;
  final AuthProvider authProvider;
  final RouteProvider? routeProvider;

  const CrowdStatusView({
    super.key,
    required this.crowdProvider,
    required this.authProvider,
    this.routeProvider,
  });

  @override
  State<CrowdStatusView> createState() => _CrowdStatusViewState();
}

class _CrowdStatusViewState extends State<CrowdStatusView> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Bus Routes', 'Railways', 'Major Hubs'];

  @override
  void initState() {
    super.initState();
    widget.crowdProvider.loadAggregations();
  }

  List<CrowdAggregationModel> _getFilteredAggregations() {
    final list = widget.crowdProvider.aggregations;
    switch (_selectedFilterIndex) {
      case 1: // Bus
        return list.where((a) => a.isRoute && !a.targetName.toLowerCase().contains('railway')).toList();
      case 2: // Railway
        return list.where((a) => a.isRoute && a.targetName.toLowerCase().contains('railway')).toList();
      case 3: // Hubs / Stops
        return list.where((a) => a.isStop).toList();
      default:
        return list;
    }
  }

  void _openSubmitCrowdSheet({int? routeId, String? routeNumber, int? stopId, String? stopName}) {
    final currentUserId = widget.authProvider.currentUser?.id ?? 1;

    SubmitCrowdBottomSheet.show(
      context,
      initialRouteId: routeId,
      initialRouteNumber: routeNumber,
      initialStopId: stopId,
      initialStopName: stopName,
      userId: currentUserId,
      crowdProvider: widget.crowdProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crowd Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Crowd Data',
            onPressed: () => widget.crowdProvider.loadAggregations(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSubmitCrowdSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Report Crowd', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.crowdProvider,
          builder: (context, _) {
            if (widget.crowdProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = _getFilteredAggregations();

            return RefreshIndicator(
              onRefresh: () => widget.crowdProvider.loadAggregations(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Network Summary Banner
                    _buildSummaryCard(),
                    const SizedBox(height: AppSpacing.md),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isSelected = _selectedFilterIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_filters[index]),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedFilterIndex = index),
                              selectedColor: AppColors.primaryLight,
                              backgroundColor: AppColors.surface,
                              labelStyle: AppTypography.labelMedium.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // List of Aggregations
                    if (items.isEmpty)
                      EmptyStateView(
                        title: 'No Crowd Reports',
                        message: 'No active crowd observations found for this category.',
                        icon: Icons.groups_outlined,
                        actionText: 'Be First to Report',
                        onAction: () => _openSubmitCrowdSheet(),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildCrowdCard(item);
                        },
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.roundedLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppSpacing.roundedPill,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sensors_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Live 30-Min Window',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Suneth’s Engine',
                style: AppTypography.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Transit Crowd Network',
            style: AppTypography.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Aggregating observations with time-decay weighting and deduplication.',
            style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdCard(CrowdAggregationModel item) {
    final isTrain = item.targetName.toLowerCase().contains('railway');

    return AppCard(
      onTap: () => _openSubmitCrowdSheet(
        routeId: item.isRoute ? item.targetId : null,
        stopId: item.isStop ? item.targetId : null,
        stopName: item.isStop ? item.targetName : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isRoute
                      ? (isTrain ? Icons.train_rounded : Icons.directions_bus_rounded)
                      : Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.targetName,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.isRoute ? 'Transit Corridor' : 'Major Transport Hub',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              CrowdMeterBadge(crowdLevel: item.currentCrowdLevel),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Detailed Meter
          CrowdMeterBadge(
            crowdLevel: item.currentCrowdLevel,
            isDetailed: true,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Metadata row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${item.sampleCount} observations',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  if (item.averageWaitTimeMinutes != null) ...[
                    const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${item.averageWaitTimeMinutes}m wait',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Text(
                  '${item.confidenceScore.toStringAsFixed(0)}% Confidence',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


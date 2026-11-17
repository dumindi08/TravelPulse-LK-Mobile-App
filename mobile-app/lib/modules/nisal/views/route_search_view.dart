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
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/journey_provider.dart';
import 'route_details_view.dart';
import 'route_results_view.dart';

/// TravelPulse LK — Route Search & Exploration Screen (Nisal)
/// Allows commuters to search by Origin & Destination, route numbers,
/// filter by transport modes (Bus / Train), and explore stops.
class RouteSearchView extends StatefulWidget {
  final RouteProvider routeProvider;
  final JourneyProvider journeyProvider;
  final AuthProvider authProvider;

  const RouteSearchView({
    super.key,
    required this.routeProvider,
    required this.journeyProvider,
    required this.authProvider,
  });

  @override
  State<RouteSearchView> createState() => _RouteSearchViewState();
}

class _RouteSearchViewState extends State<RouteSearchView> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _routeNumberController = TextEditingController();

  // Quick transit hub chips in Sri Lanka
  final List<String> _quickHubs = [
    'Colombo Fort',
    'Maharagama',
    'Pettah',
    'Kollupitiya',
    'Panadura',
    'Kandy',
    'Malabe',
    'Gampaha',
  ];

  @override
  void initState() {
    super.initState();
    _originController.text = widget.routeProvider.originQuery;
    _destinationController.text = widget.routeProvider.destinationQuery;
    _routeNumberController.text = widget.routeProvider.searchQuery;
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _routeNumberController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final orig = _originController.text.trim();
    final dest = _destinationController.text.trim();
    final routeNum = _routeNumberController.text.trim();

    widget.routeProvider.setOrigin(orig);
    widget.routeProvider.setDestination(dest);
    widget.routeProvider.setSearchQuery(routeNum);

    if (orig.isNotEmpty || dest.isNotEmpty) {
      widget.routeProvider.searchByOriginDestination(
        origin: orig,
        destination: dest,
      );

      // Navigate to dedicated results view
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RouteResultsView(
            origin: orig,
            destination: dest,
            routeProvider: widget.routeProvider,
            journeyProvider: widget.journeyProvider,
            authProvider: widget.authProvider,
          ),
        ),
      );
    } else {
      widget.routeProvider.loadRoutes();
    }
  }

  void _swapEndpoints() {
    final temp = _originController.text;
    _originController.text = _destinationController.text;
    _destinationController.text = temp;

    widget.routeProvider.setOrigin(_originController.text);
    widget.routeProvider.setDestination(_destinationController.text);

    if (_originController.text.isNotEmpty || _destinationController.text.isNotEmpty) {
      widget.routeProvider.searchByOriginDestination();
    }
  }

  void _selectHub(String hub) {
    if (_originController.text.isEmpty) {
      _originController.text = hub;
      widget.routeProvider.setOrigin(hub);
    } else {
      _destinationController.text = hub;
      widget.routeProvider.setDestination(hub);
    }
    setState(() {});
  }

  void _clearAll() {
    _originController.clear();
    _destinationController.clear();
    _routeNumberController.clear();
    widget.routeProvider.clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Routes & Transit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear & Reset',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Origin & Destination Input Box
              _buildSearchCard(),
              const SizedBox(height: AppSpacing.md),

              // 2. Transport Mode Selector Chips
              _buildModeSelector(),
              const SizedBox(height: AppSpacing.md),

              // 3. Quick Hub Recommendation Chips
              _buildQuickHubs(),
              const SizedBox(height: AppSpacing.lg),

              // 4. Live Search Results / Routes List
              _buildResultsHeader(),
              const SizedBox(height: AppSpacing.sm),
              _buildResultsList(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Timeline connector dots
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 38,
                    color: AppColors.borderDark,
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

              // Text Fields
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _originController,
                      decoration: InputDecoration(
                        hintText: 'Enter origin (e.g. Colombo Fort)',
                        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.roundedSm,
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _originController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _originController.clear();
                                  widget.routeProvider.setOrigin('');
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        widget.routeProvider.setOrigin(val);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: 'Enter destination (e.g. Maharagama)',
                        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.roundedSm,
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _destinationController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _destinationController.clear();
                                  widget.routeProvider.setDestination('');
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        widget.routeProvider.setDestination(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Swap Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                  tooltip: 'Swap Origin and Destination',
                  onPressed: _swapEndpoints,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Route number direct filter
          TextField(
            controller: _routeNumberController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.tag_rounded, size: 18, color: AppColors.textSecondary),
              hintText: 'Route number (optional, e.g. 138, 100, MAIN-RLY)',
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.roundedSm,
                borderSide: BorderSide.none,
              ),
              suffixIcon: _routeNumberController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _routeNumberController.clear();
                        widget.routeProvider.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              widget.routeProvider.setSearchQuery(val);
              setState(() {});
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Search Button
          AppButton(
            text: 'Find Transit Routes',
            leadingIcon: Icons.search_rounded,
            onPressed: _onSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final current = widget.routeProvider.selectedTransportType;

    return Row(
      children: [
        _buildModeChip('All Modes', 'all', Icons.all_inclusive_rounded, current == 'all'),
        const SizedBox(width: 8),
        _buildModeChip('Bus Only', 'bus', Icons.directions_bus_rounded, current == 'bus'),
        const SizedBox(width: 8),
        _buildModeChip('Train Only', 'train', Icons.train_rounded, current == 'train'),
      ],
    );
  }

  Widget _buildModeChip(String label, String value, IconData icon, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => widget.routeProvider.setTransportTypeFilter(value),
        borderRadius: AppSpacing.roundedPill,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: AppSpacing.roundedPill,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? AppColors.textInverse : AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickHubs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Sri Lankan Transit Hubs', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _quickHubs.map((hub) {
            return InkWell(
              onTap: () => _selectHub(hub),
              borderRadius: AppSpacing.roundedPill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppSpacing.roundedPill,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_outlined, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(hub, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return ListenableBuilder(
      listenable: widget.routeProvider,
      builder: (context, _) {
        final count = widget.routeProvider.searchResults.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Available Transit Lines ($count)', style: AppTypography.titleMedium),
            if (widget.routeProvider.originQuery.isNotEmpty || widget.routeProvider.destinationQuery.isNotEmpty)
              TextButton(
                onPressed: _clearAll,
                child: const Text('Reset'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildResultsList() {
    return ListenableBuilder(
      listenable: widget.routeProvider,
      builder: (context, _) {
        if (widget.routeProvider.isLoading || widget.routeProvider.isSearching) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final list = widget.routeProvider.searchResults;

        if (list.isEmpty) {
          return EmptyStateView(
            title: 'No Matching Routes Found',
            message: 'Try adjusting your origin, destination, or transport mode filter.',
            icon: Icons.search_off_rounded,
            actionText: 'Reset Search',
            onAction: _clearAll,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final route = list[index];
            final isFav = widget.routeProvider.isFavorite(route.id);

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
                        child: Text(
                          route.routeNumber,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (route.operator != null)
                        StatusBadge.operator(route.operator!),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFav ? AppColors.warning : AppColors.textMuted,
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
                          const SizedBox(width: 5),
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
          },
        );
      },
    );
  }
}


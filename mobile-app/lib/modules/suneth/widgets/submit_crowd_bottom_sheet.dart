import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../nisal/models/route_model.dart';
import '../../nisal/models/stop_model.dart';
import '../providers/crowd_provider.dart';

/// TravelPulse LK — Quick Crowd Observation Submission Sheet (Suneth)
/// Allows commuters to report real-time vehicle or stop crowding.
class SubmitCrowdBottomSheet extends StatefulWidget {
  final int? initialRouteId;
  final String? initialRouteNumber;
  final int? initialStopId;
  final String? initialStopName;
  final int userId;
  final String? token;
  final CrowdProvider crowdProvider;
  final List<RouteModel>? availableRoutes;
  final List<StopModel>? availableStops;

  const SubmitCrowdBottomSheet({
    super.key,
    this.initialRouteId,
    this.initialRouteNumber,
    this.initialStopId,
    this.initialStopName,
    required this.userId,
    this.token,
    required this.crowdProvider,
    this.availableRoutes,
    this.availableStops,
  });

  static Future<bool?> show(
    BuildContext context, {
    int? initialRouteId,
    String? initialRouteNumber,
    int? initialStopId,
    String? initialStopName,
    required int userId,
    String? token,
    required CrowdProvider crowdProvider,
    List<RouteModel>? availableRoutes,
    List<StopModel>? availableStops,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SubmitCrowdBottomSheet(
          initialRouteId: initialRouteId,
          initialRouteNumber: initialRouteNumber,
          initialStopId: initialStopId,
          initialStopName: initialStopName,
          userId: userId,
          token: token,
          crowdProvider: crowdProvider,
          availableRoutes: availableRoutes,
          availableStops: availableStops,
        ),
      ),
    );
  }

  @override
  State<SubmitCrowdBottomSheet> createState() => _SubmitCrowdBottomSheetState();
}

class _SubmitCrowdBottomSheetState extends State<SubmitCrowdBottomSheet> {
  late bool _isRouteTarget;
  int? _selectedRouteId;
  int? _selectedStopId;
  String _selectedCrowdLevel = 'moderate';
  int? _passengerWaitTimeMinutes;

  final List<int> _commonWaitTimes = [5, 10, 15, 20, 30];

  final List<Map<String, dynamic>> _crowdOptions = [
    {
      'level': 'empty',
      'label': 'Light',
      'desc': 'Seats available',
      'icon': Icons.airline_seat_recline_normal_rounded,
      'color': AppColors.crowdEmpty,
    },
    {
      'level': 'moderate',
      'label': 'Moderate',
      'desc': 'Few seats left',
      'icon': Icons.groups_rounded,
      'color': AppColors.crowdModerate,
    },
    {
      'level': 'crowded',
      'label': 'Heavy',
      'desc': 'Standing room only',
      'icon': Icons.group_add_rounded,
      'color': AppColors.crowdCrowded,
    },
    {
      'level': 'very_crowded',
      'label': 'Packed',
      'desc': 'Hard to board',
      'icon': Icons.warning_amber_rounded,
      'color': AppColors.crowdPacked,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialStopId != null) {
      _isRouteTarget = false;
      _selectedStopId = widget.initialStopId;
    } else {
      _isRouteTarget = true;
      _selectedRouteId = widget.initialRouteId ?? 1;
    }
  }

  Future<void> _handleSubmit() async {
    final success = await widget.crowdProvider.submitCrowdEstimate(
      routeId: _isRouteTarget ? _selectedRouteId : null,
      stopId: !_isRouteTarget ? _selectedStopId : null,
      crowdLevel: _selectedCrowdLevel,
      passengerWaitTimeMinutes: _passengerWaitTimeMinutes,
      userId: widget.userId,
      token: widget.token,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crowd observation recorded! Thank you for helping commuters.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.crowdProvider.errorMessage ?? 'Submission failed.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report Live Crowd', style: AppTypography.headlineMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Text(
                      'Live Intelligence',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Help fellow commuters by sharing real-time crowding conditions.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.md),

              // Target Selector (Route vs Stop)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppSpacing.roundedMd,
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isRouteTarget = true;
                          _selectedRouteId ??= widget.initialRouteId ?? 1;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isRouteTarget ? AppColors.surface : Colors.transparent,
                            borderRadius: AppSpacing.roundedSm,
                            boxShadow: _isRouteTarget
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Transit Vehicle / Route',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: _isRouteTarget ? FontWeight.w700 : FontWeight.w500,
                              color: _isRouteTarget ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _isRouteTarget = false;
                          _selectedStopId ??= widget.initialStopId ?? 101;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isRouteTarget ? AppColors.surface : Colors.transparent,
                            borderRadius: AppSpacing.roundedSm,
                            boxShadow: !_isRouteTarget
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Stop / Station Hub',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: !_isRouteTarget ? FontWeight.w700 : FontWeight.w500,
                              color: !_isRouteTarget ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Selected Target Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isRouteTarget ? Icons.directions_bus_rounded : Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRouteTarget ? 'Selected Corridor' : 'Selected Hub',
                            style: AppTypography.caption,
                          ),
                          Text(
                            _isRouteTarget
                                ? (widget.initialRouteNumber != null
                                    ? 'Route ${widget.initialRouteNumber}'
                                    : 'Route 138 (Pettah - Homagama)')
                                : (widget.initialStopName ?? 'Pettah Main Bus Stand'),
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Crowd Level Selection (4 options)
              Text('How crowded is it right now?', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: _crowdOptions.map((opt) {
                  final isSelected = _selectedCrowdLevel == opt['level'];
                  final Color optColor = opt['color'] as Color;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCrowdLevel = opt['level'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? optColor.withOpacity(0.12) : AppColors.surface,
                            borderRadius: AppSpacing.roundedMd,
                            border: Border.all(
                              color: isSelected ? optColor : AppColors.border,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                opt['icon'] as IconData,
                                color: isSelected ? optColor : AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                opt['label'] as String,
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? optColor : AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt['desc'] as String,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Optional Wait Time Selector
              Text('Estimated wait time (Optional)', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                children: _commonWaitTimes.map((mins) {
                  final isSelected = _passengerWaitTimeMinutes == mins;
                  return ChoiceChip(
                    label: Text('$mins mins'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _passengerWaitTimeMinutes = selected ? mins : null;
                      });
                    },
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              AppButton(
                text: 'Submit Live Observation',
                leadingIcon: Icons.send_rounded,
                isLoading: widget.crowdProvider.isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


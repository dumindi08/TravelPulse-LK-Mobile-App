import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../nisal/providers/auth_provider.dart';
import '../models/alert_subscription_model.dart';
import '../providers/alert_provider.dart';

/// TravelPulse LK — Commuter Alert Notification Settings Screen (Thimaya)
/// Configures Table 19 (`alert_subscriptions`) preferences and FCM push notification options.
class AlertSettingsView extends StatefulWidget {
  final AlertProvider alertProvider;
  final AuthProvider authProvider;

  const AlertSettingsView({
    super.key,
    required this.alertProvider,
    required this.authProvider,
  });

  @override
  State<AlertSettingsView> createState() => _AlertSettingsViewState();
}

class _AlertSettingsViewState extends State<AlertSettingsView> {
  late bool _pushEnabled;
  late bool _weatherAlerts;
  late bool _roadHazards;
  late bool _transitDisruptions;
  late bool _soundVibrate;
  late double _alertRadiusKm;
  late String _subscriptionType;

  @override
  void initState() {
    super.initState();
    final sub = widget.alertProvider.subscription ??
        AlertSubscriptionModel.defaults(widget.authProvider.currentUser?.id ?? 1);

    _pushEnabled = sub.pushNotificationsEnabled;
    _weatherAlerts = sub.weatherAlerts;
    _roadHazards = sub.roadHazards;
    _transitDisruptions = sub.transitDisruptions;
    _soundVibrate = sub.soundAndVibrate;
    _alertRadiusKm = sub.radiusKm ?? 5.0;
    _subscriptionType = sub.subscriptionType;
  }

  Future<void> _handleSave() async {
    final userId = widget.authProvider.currentUser?.id ?? 1;
    final updated = AlertSubscriptionModel(
      id: widget.alertProvider.subscription?.id ?? 1,
      userId: userId,
      subscriptionType: _subscriptionType,
      radiusKm: _alertRadiusKm,
      isActive: _pushEnabled,
      pushNotificationsEnabled: _pushEnabled,
      weatherAlerts: _weatherAlerts,
      roadHazards: _roadHazards,
      transitDisruptions: _transitDisruptions,
      soundAndVibrate: _soundVibrate,
    );

    final success = await widget.alertProvider.updatePreferences(
      updated,
      token: widget.authProvider.token,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved successfully.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.alertProvider.errorMessage ?? 'Failed to save preferences.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: AppButton(
            text: 'Save Notification Settings',
            isLoading: widget.alertProvider.isSaving,
            onPressed: _handleSave,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master Push Toggle Card
              AppCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Push Notifications', style: AppTypography.titleMedium),
                  subtitle: const Text(
                    'Receive real-time mobile push alerts for delays, hazards, and emergency broadcasts.',
                    style: AppTypography.caption,
                  ),
                  activeColor: AppColors.primary,
                  value: _pushEnabled,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Alert Category Preferences
              Text('Alert Categories', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Severe Weather Emergencies', style: AppTypography.bodySmall),
                      subtitle: const Text('Flash floods, monsoonal warnings, gale-force winds', style: AppTypography.caption),
                      activeColor: AppColors.primary,
                      value: _weatherAlerts,
                      onChanged: _pushEnabled ? (val) => setState(() => _weatherAlerts = val) : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Transport Service Disruptions', style: AppTypography.bodySmall),
                      subtitle: const Text('Train cancellations, breakdowns, major corridor delays', style: AppTypography.caption),
                      activeColor: AppColors.primary,
                      value: _transitDisruptions,
                      onChanged: _pushEnabled ? (val) => setState(() => _transitDisruptions = val) : null,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Physical Road Hazards', style: AppTypography.bodySmall),
                      subtitle: const Text('Road closures, deep potholes, fallen trees, collisions', style: AppTypography.caption),
                      activeColor: AppColors.primary,
                      value: _roadHazards,
                      onChanged: _pushEnabled ? (val) => setState(() => _roadHazards = val) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Geofenced Alert Radius
              Text('Localized Alert Radius', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Radius around your position', style: AppTypography.bodySmall),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppSpacing.roundedPill,
                          ),
                          child: Text(
                            '${_alertRadiusKm.toStringAsFixed(0)} km',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _alertRadiusKm,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      label: '${_alertRadiusKm.toStringAsFixed(0)} km',
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      onChanged: _pushEnabled ? (val) => setState(() => _alertRadiusKm = val) : null,
                    ),
                    Text(
                      'Receive alerts for incidents and disruptions occurring within this perimeter of your location.',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Sound and Vibration
              Text('Alert Sound & Feedback', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Sound & Vibration', style: AppTypography.bodySmall),
                  subtitle: const Text('Play audible ringtone and vibrate on high-severity alerts', style: AppTypography.caption),
                  activeColor: AppColors.primary,
                  value: _soundVibrate,
                  onChanged: _pushEnabled ? (val) => setState(() => _soundVibrate = val) : null,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // FCM Push Dispatch Architecture Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_done_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Push notification delivery is managed by Firebase Cloud Messaging (FCM) and verified via Table 20 delivery audit logs.',
                        style: AppTypography.caption.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}


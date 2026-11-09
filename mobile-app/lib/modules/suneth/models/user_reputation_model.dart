import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// TravelPulse LK — Commuter Reputation & Trust Model (Suneth)
/// Represents commuter trustworthiness and credibility based on Table 12: `user_reputations`
class UserReputationModel {
  final int userId;
  final double reputationScore; // 0.00 to 100.00
  final int totalReportsSubmitted;
  final int verifiedReportsCount;
  final int rejectedReportsCount;
  final int totalVotesCast;
  final DateTime updatedAt;

  UserReputationModel({
    required this.userId,
    required this.reputationScore,
    required this.totalReportsSubmitted,
    required this.verifiedReportsCount,
    required this.rejectedReportsCount,
    required this.totalVotesCast,
    required this.updatedAt,
  });

  /// Derived trust tier label
  String get trustTier {
    if (reputationScore >= 90.0) return 'Elite Contributor';
    if (reputationScore >= 75.0) return 'Trusted Commuter';
    if (reputationScore >= 50.0) return 'Active Contributor';
    if (reputationScore >= 25.0) return 'Regular Commuter';
    return 'New Commuter';
  }

  /// Verification accuracy percentage
  double get accuracyRate {
    if (totalReportsSubmitted == 0) return 100.0;
    return (verifiedReportsCount / totalReportsSubmitted) * 100.0;
  }

  Color get tierColor {
    if (reputationScore >= 85.0) return AppColors.primary;
    if (reputationScore >= 70.0) return AppColors.success;
    if (reputationScore >= 50.0) return AppColors.info;
    if (reputationScore >= 30.0) return AppColors.warning;
    return AppColors.textSecondary;
  }

  factory UserReputationModel.fromJson(Map<String, dynamic> json) {
    return UserReputationModel(
      userId: json['userId'] as int? ?? json['user_id'] as int? ?? 0,
      reputationScore: (json['reputationScore'] as num?)?.toDouble() ??
          (json['reputation_score'] as num?)?.toDouble() ??
          10.0,
      totalReportsSubmitted: json['totalReportsSubmitted'] as int? ??
          json['total_reports_submitted'] as int? ??
          0,
      verifiedReportsCount: json['verifiedReportsCount'] as int? ??
          json['verified_reports_count'] as int? ??
          0,
      rejectedReportsCount: json['rejectedReportsCount'] as int? ??
          json['rejected_reports_count'] as int? ??
          0,
      totalVotesCast: json['totalVotesCast'] as int? ??
          json['total_votes_cast'] as int? ??
          0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : (json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reputationScore': reputationScore,
      'totalReportsSubmitted': totalReportsSubmitted,
      'verifiedReportsCount': verifiedReportsCount,
      'rejectedReportsCount': rejectedReportsCount,
      'totalVotesCast': totalVotesCast,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Default starting reputation for new commuters
  factory UserReputationModel.initial(int userId) {
    return UserReputationModel(
      userId: userId,
      reputationScore: 10.0,
      totalReportsSubmitted: 0,
      verifiedReportsCount: 0,
      rejectedReportsCount: 0,
      totalVotesCast: 0,
      updatedAt: DateTime.now(),
    );
  }
}


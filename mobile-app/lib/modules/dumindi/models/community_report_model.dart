/// TravelPulse LK — Community Report Model (Dumindi)
/// Follows specific project guidelines:
/// - Anonymous reporting option
/// - Mandatory reason capture for disruptions (not invented severity)
/// - Ownership verification (users manage only their own reports)
/// - Integrated reliability score and confidence state (Suneth)
class CommunityReportModel {
  final int id;
  final int userId;
  final String userName;
  final bool isAnonymous;
  final int categoryId;
  final String categoryName;
  final int? routeId;
  final String? routeNumber;
  final int? stopId;
  final String? stopName;
  final double latitude;
  final double longitude;
  final String locationDescription;
  final String title;
  final String description;
  final String? disruptionReason; // Specific reason e.g. Vehicle Breakdown
  final String? mediaUrl;
  final String status; // 'submitted', 'verified', 'disputed', 'resolved', 'rejected'
  final double reliabilityScore;
  final String confidenceStatus; // 'unverified', 'plausible', 'verified', 'disputed'
  final int upvotesCount;
  final int downvotesCount;
  final String? userVote; // Current commuter's vote: 'upvote', 'downvote', null
  final DateTime createdAt;
  final DateTime? resolvedAt;

  CommunityReportModel({
    required this.id,
    required this.userId,
    this.userName = 'Commuter',
    this.isAnonymous = false,
    required this.categoryId,
    required this.categoryName,
    this.routeId,
    this.routeNumber,
    this.stopId,
    this.stopName,
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.title,
    required this.description,
    this.disruptionReason,
    this.mediaUrl,
    this.status = 'submitted',
    this.reliabilityScore = 10.0,
    this.confidenceStatus = 'unverified',
    this.upvotesCount = 0,
    this.downvotesCount = 0,
    this.userVote,
    required this.createdAt,
    this.resolvedAt,
  });

  String get displayReporter => isAnonymous ? 'Anonymous Commuter' : userName;
  bool get isVerified => status == 'verified' || confidenceStatus == 'verified';
  bool get isDisputed => status == 'disputed' || confidenceStatus == 'disputed';
  bool get isResolved => status == 'resolved';

  bool isOwnedBy(int? currentUserId) {
    if (currentUserId == null) return false;
    return userId == currentUserId;
  }

  CommunityReportModel copyWith({
    String? status,
    double? reliabilityScore,
    String? confidenceStatus,
    int? upvotesCount,
    int? downvotesCount,
    String? userVote,
    DateTime? resolvedAt,
  }) {
    return CommunityReportModel(
      id: id,
      userId: userId,
      userName: userName,
      isAnonymous: isAnonymous,
      categoryId: categoryId,
      categoryName: categoryName,
      routeId: routeId,
      routeNumber: routeNumber,
      stopId: stopId,
      stopName: stopName,
      latitude: latitude,
      longitude: longitude,
      locationDescription: locationDescription,
      title: title,
      description: description,
      disruptionReason: disruptionReason,
      mediaUrl: mediaUrl,
      status: status ?? this.status,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      confidenceStatus: confidenceStatus ?? this.confidenceStatus,
      upvotesCount: upvotesCount ?? this.upvotesCount,
      downvotesCount: downvotesCount ?? this.downvotesCount,
      userVote: userVote ?? this.userVote,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory CommunityReportModel.fromJson(Map<String, dynamic> json) {
    return CommunityReportModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? 'Commuter',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      categoryId: json['categoryId'] as int? ?? 1,
      categoryName: json['categoryName'] as String? ?? 'General Report',
      routeId: json['routeId'] as int?,
      routeNumber: json['routeNumber'] as String?,
      stopId: json['stopId'] as int?,
      stopName: json['stopName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationDescription: json['locationDescription'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      disruptionReason: json['disruptionReason'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      status: json['status'] as String? ?? 'submitted',
      reliabilityScore: (json['reliabilityScore'] as num?)?.toDouble() ?? 10.0,
      confidenceStatus: json['confidenceStatus'] as String? ?? 'unverified',
      upvotesCount: json['upvotesCount'] as int? ?? json['upvotes'] as int? ?? 0,
      downvotesCount: json['downvotesCount'] as int? ?? json['downvotes'] as int? ?? 0,
      userVote: json['userVote'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'isAnonymous': isAnonymous,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'routeId': routeId,
      'routeNumber': routeNumber,
      'stopId': stopId,
      'stopName': stopName,
      'latitude': latitude,
      'longitude': longitude,
      'locationDescription': locationDescription,
      'title': title,
      'description': description,
      'disruptionReason': disruptionReason,
      'mediaUrl': mediaUrl,
      'status': status,
      'reliabilityScore': reliabilityScore,
      'confidenceStatus': confidenceStatus,
      'upvotesCount': upvotesCount,
      'downvotesCount': downvotesCount,
      'userVote': userVote,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}


/// TravelPulse LK — User Model (Nisal)
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role; // 'commuter', 'moderator', 'admin'
  final bool isActive;
  final UserProfileModel? profile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.role = 'commuter',
    this.isActive = true,
    this.profile,
  });

  bool get isModerator => role == 'moderator' || role == 'admin';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String? ?? 'commuter',
      isActive: json['isActive'] as bool? ?? true,
      profile: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isActive': isActive,
      'profile': profile?.toJson(),
    };
  }
}

class UserProfileModel {
  final int? homeStopId;
  final String? homeStopName;
  final int? workStopId;
  final String? workStopName;
  final String preferredTransportMode; // 'bus', 'train', 'any'
  final String? bio;

  UserProfileModel({
    this.homeStopId,
    this.homeStopName,
    this.workStopId,
    this.workStopName,
    this.preferredTransportMode = 'any',
    this.bio,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      homeStopId: json['homeStopId'] as int?,
      homeStopName: json['homeStopName'] as String?,
      workStopId: json['workStopId'] as int?,
      workStopName: json['workStopName'] as String?,
      preferredTransportMode: json['preferredTransportMode'] as String? ?? 'any',
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homeStopId': homeStopId,
      'homeStopName': homeStopName,
      'workStopId': workStopId,
      'workStopName': workStopName,
      'preferredTransportMode': preferredTransportMode,
      'bio': bio,
    };
  }
}


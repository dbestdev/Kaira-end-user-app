class FavoriteArtisanModel {
  final String id;
  final String userId;
  final String artisanId;
  final ArtisanInfo artisan;
  final DateTime createdAt;

  FavoriteArtisanModel({
    required this.id,
    required this.userId,
    required this.artisanId,
    required this.artisan,
    required this.createdAt,
  });

  factory FavoriteArtisanModel.fromJson(Map<String, dynamic> json) {
    return FavoriteArtisanModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      artisanId: json['artisanId'] ?? '',
      artisan: ArtisanInfo.fromJson(json['artisan'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'artisanId': artisanId,
      'artisan': artisan.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ArtisanInfo {
  final String id;
  final String? businessName;
  final String? businessPhone;
  final String? businessAddress;
  final String? businessCity;
  final String? businessState;
  final int yearsOfExperience;
  final double rating;
  final int totalReviews;
  final int completedJobs;
  final bool isAvailable;
  final List<String> specializations;
  final List<ArtisanService> services;
  final ArtisanUser user;

  ArtisanInfo({
    required this.id,
    this.businessName,
    this.businessPhone,
    this.businessAddress,
    this.businessCity,
    this.businessState,
    required this.yearsOfExperience,
    required this.rating,
    required this.totalReviews,
    required this.completedJobs,
    required this.isAvailable,
    required this.specializations,
    required this.services,
    required this.user,
  });

  factory ArtisanInfo.fromJson(Map<String, dynamic> json) {
    return ArtisanInfo(
      id: json['id'] ?? '',
      businessName: json['businessName'],
      businessPhone: json['businessPhone'],
      businessAddress: json['businessAddress'],
      businessCity: json['businessCity'],
      businessState: json['businessState'],
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      rating: _parseDouble(json['rating']),
      totalReviews: json['totalReviews'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      specializations: List<String>.from(json['specializations'] ?? []),
      services:
          (json['services'] as List<dynamic>?)
              ?.map((service) => ArtisanService.fromJson(service))
              .toList() ??
          [],
      user: ArtisanUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      'businessPhone': businessPhone,
      'businessAddress': businessAddress,
      'businessCity': businessCity,
      'businessState': businessState,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'totalReviews': totalReviews,
      'completedJobs': completedJobs,
      'isAvailable': isAvailable,
      'specializations': specializations,
      'services': services.map((service) => service.toJson()).toList(),
      'user': user.toJson(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  String get displayName =>
      businessName ?? '${user.firstName} ${user.lastName}';
  String get location => [
    businessCity,
    businessState,
  ].where((e) => e != null && e.isNotEmpty).join(', ');
}

class ArtisanService {
  final String id;
  final String name;
  final String description;
  final double? basePrice;
  final double? hourlyRate;

  ArtisanService({
    required this.id,
    required this.name,
    required this.description,
    this.basePrice,
    this.hourlyRate,
  });

  factory ArtisanService.fromJson(Map<String, dynamic> json) {
    return ArtisanService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: json['basePrice']?.toDouble(),
      hourlyRate: json['hourlyRate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'hourlyRate': hourlyRate,
    };
  }
}

class ArtisanUser {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  ArtisanUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory ArtisanUser.fromJson(Map<String, dynamic> json) {
    return ArtisanUser(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
    };
  }

  String get fullName => '$firstName $lastName';
}

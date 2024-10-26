import 'package:json_annotation/json_annotation.dart';

class Store {
  String? id;
  String storeName;
  String businessType;
  String? photoPath;
  double latitude;
  double longitude;
  String address;
  String contactPerson;
  String phoneNumber;
  String? email;
  DateTime visitDate;
  String businessHours;
  String? website;
  Map<String, String>? socialMedia;
  int partnershipPotential; // 1-5 rating
  String? notes;
  DateTime? followUpDate;
  DateTime createdAt;
  DateTime updatedAt;

  Store({
    this.id,
    required this.storeName,
    required this.businessType,
    this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.contactPerson,
    required this.phoneNumber,
    this.email,
    required this.visitDate,
    required this.businessHours,
    this.website,
    this.socialMedia,
    required this.partnershipPotential,
    this.notes,
    this.followUpDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  // Create a copy of the store with updated fields
  Store copyWith({
    String? id,
    String? storeName,
    String? businessType,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? address,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    DateTime? visitDate,
    String? businessHours,
    String? website,
    Map<String, String>? socialMedia,
    int? partnershipPotential,
    String? notes,
    DateTime? followUpDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      businessType: businessType ?? this.businessType,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      visitDate: visitDate ?? this.visitDate,
      businessHours: businessHours ?? this.businessHours,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      partnershipPotential: partnershipPotential ?? this.partnershipPotential,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert Store to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'storeName': storeName,
    'businessType': businessType,
    'photoPath': photoPath,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'contactPerson': contactPerson,
    'phoneNumber': phoneNumber,
    'email': email,
    'visitDate': visitDate.toIso8601String(),
    'businessHours': businessHours,
    'website': website,
    'socialMedia': socialMedia,
    'partnershipPotential': partnershipPotential,
    'notes': notes,
    'followUpDate': followUpDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Create Store from JSON
  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json['id'] as String?,
    storeName: json['storeName'] as String,
    businessType: json['businessType'] as String,
    photoPath: json['photoPath'] as String?,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    address: json['address'] as String,
    contactPerson: json['contactPerson'] as String,
    phoneNumber: json['phoneNumber'] as String,
    email: json['email'] as String?,
    visitDate: DateTime.parse(json['visitDate'] as String),
    businessHours: json['businessHours'] as String,
    website: json['website'] as String?,
    socialMedia: (json['socialMedia'] as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as String),
    ),
    partnershipPotential: json['partnershipPotential'] as int,
    notes: json['notes'] as String?,
    followUpDate: json['followUpDate'] != null
        ? DateTime.parse(json['followUpDate'] as String)
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  // Create empty store with default values
  factory Store.empty() => Store(
    storeName: '',
    businessType: '',
    latitude: 0.0,
    longitude: 0.0,
    address: '',
    contactPerson: '',
    phoneNumber: '',
    visitDate: DateTime.now(),
    businessHours: '',
    partnershipPotential: 3,
  );

  // Helper method to check if follow-up is due
  bool get isFollowUpDue {
    if (followUpDate == null) return false;
    return followUpDate!.isBefore(DateTime.now());
  }

  // Helper method to get days until follow-up
  int? get daysUntilFollowUp {
    if (followUpDate == null) return null;
    return followUpDate!.difference(DateTime.now()).inDays;
  }

  // Helper method to get formatted coordinates
  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Helper method to get partnership rating as stars
  String get partnershipStars {
    return '⭐' * partnershipPotential + '☆' * (5 - partnershipPotential);
  }

  // Helper method to get time since last visit
  String get timeSinceVisit {
    final difference = DateTime.now().difference(visitDate);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'Today';
    }
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'Store{id: $id, storeName: $storeName, businessType: $businessType}';
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store && other.id == id;
  }

  // Override hashcode
  @override
  int get hashCode => id.hashCode;
}
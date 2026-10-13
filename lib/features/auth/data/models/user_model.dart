import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user document stored in the Firestore `users` collection.
class UserModel {
  const UserModel({
    required this.uid,
    required this.phone,
    this.name,
    this.email,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.bloodGroup,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.existingConditions,
    this.allergies,
    this.emergencyContacts,
    this.isProfileComplete = false,
    this.createdAt,
    this.lastLoginAt,
  });

  final String uid;
  final String phone;
  final String? name;
  final String? email;
  final String? profilePictureUrl;
  final String? dateOfBirth;
  final String? bloodGroup;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final List<String>? existingConditions;
  final List<String>? allergies;
  final List<Map<String, dynamic>>? emergencyContacts;
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  /// Constructs a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      phone: data['phone'] as String? ?? '',
      name: data['name'] as String?,
      email: data['email'] as String?,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      dateOfBirth: data['dateOfBirth'] as String?,
      bloodGroup: data['bloodGroup'] as String?,
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      existingConditions: (data['existingConditions'] as List<dynamic>?)?.map((e) => e as String).toList(),
      allergies: (data['allergies'] as List<dynamic>?)?.map((e) => e as String).toList(),
      emergencyContacts: (data['emergencyContacts'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts the model to a map for Firestore writes.
  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'phone': phone,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (existingConditions != null) 'existingConditions': existingConditions,
        if (allergies != null) 'allergies': allergies,
        if (emergencyContacts != null) 'emergencyContacts': emergencyContacts,
        'isProfileComplete': isProfileComplete,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

  UserModel copyWith({
    String? uid,
    String? phone,
    String? name,
    String? email,
    String? profilePictureUrl,
    String? dateOfBirth,
    String? bloodGroup,
    int? age,
    String? gender,
    double? height,
    double? weight,
    List<String>? existingConditions,
    List<String>? allergies,
    List<Map<String, dynamic>>? emergencyContacts,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      existingConditions: existingConditions ?? this.existingConditions,
      allergies: allergies ?? this.allergies,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, phone: $phone, name: $name)';
}

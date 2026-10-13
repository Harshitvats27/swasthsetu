import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final List<String> specializations;
  final List<String> qualifications;
  final List<String> languages;
  final int experienceYears;
  final double consultationFee;
  final String clinicName;
  final bool isHospital;
  /// For hospital-affiliated doctors: the Firestore document ID of the hospital.
  final String? hospitalId;
  /// For independent clinic doctors: the lat/lng of their clinic.
  final GeoPoint? clinicGeoPoint;
  final double rating;
  final int reviewsCount;
  final String? profilePictureUrl;
  final List<String> availabilitySlots;
  final List<String> availableDays;
  final List<String> daysOff;
  final String? startTime;
  final String? endTime;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specializations,
    required this.qualifications,
    required this.languages,
    required this.experienceYears,
    required this.consultationFee,
    required this.clinicName,
    required this.isHospital,
    this.hospitalId,
    this.clinicGeoPoint,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.profilePictureUrl,
    required this.availabilitySlots,
    this.availableDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    this.daysOff = const ['Saturday', 'Sunday'],
    this.startTime = '09:00 AM',
    this.endTime = '05:00 PM',
  });

  /// Returns the relevant location — hospital lat/lng must be resolved separately
  /// via [hospitalId]; for clinic doctors this is set directly.
  GeoPoint? get locationGeoPoint => clinicGeoPoint;

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
      qualifications: List<String>.from(data['qualifications'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      experienceYears: data['experienceYears'] ?? 0,
      consultationFee: (data['consultationFee'] ?? 0).toDouble(),
      clinicName: data['clinicName'] ?? '',
      isHospital: data['isHospital'] ?? false,
      hospitalId: data['hospitalId'],
      clinicGeoPoint: data['clinicGeoPoint'] as GeoPoint?,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      profilePictureUrl: data['profilePictureUrl'],
      availabilitySlots: List<String>.from(data['availabilitySlots'] ?? []),
      availableDays: List<String>.from(data['availableDays'] ?? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']),
      daysOff: List<String>.from(data['daysOff'] ?? ['Saturday', 'Sunday']),
      startTime: data['startTime'] as String? ?? '09:00 AM',
      endTime: data['endTime'] as String? ?? '05:00 PM',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specializations': specializations,
      'qualifications': qualifications,
      'languages': languages,
      'experienceYears': experienceYears,
      'consultationFee': consultationFee,
      'clinicName': clinicName,
      'isHospital': isHospital,
      if (hospitalId != null) 'hospitalId': hospitalId,
      if (clinicGeoPoint != null) 'clinicGeoPoint': clinicGeoPoint,
      'rating': rating,
      'reviewsCount': reviewsCount,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      'availabilitySlots': availabilitySlots,
      'availableDays': availableDays,
      'daysOff': daysOff,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

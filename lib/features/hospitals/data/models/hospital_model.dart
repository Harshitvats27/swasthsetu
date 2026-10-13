import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String? imageUrl;
  final GeoPoint geoPoint;
  final List<String> specialties;
  final List<String> facilities;
  final int totalBeds;
  final double rating;
  final int reviewsCount;
  final bool isOpen24x7;
  final List<String> doctorIds; // references to doctor documents

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.phone,
    this.imageUrl,
    required this.geoPoint,
    required this.specialties,
    required this.facilities,
    required this.totalBeds,
    required this.rating,
    required this.reviewsCount,
    required this.isOpen24x7,
    required this.doctorIds,
  });

  factory HospitalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HospitalModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      phone: data['phone'] ?? '',
      imageUrl: data['imageUrl'],
      geoPoint: data['geoPoint'] as GeoPoint,
      specialties: List<String>.from(data['specialties'] ?? []),
      facilities: List<String>.from(data['facilities'] ?? []),
      totalBeds: data['totalBeds'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      isOpen24x7: data['isOpen24x7'] ?? false,
      doctorIds: List<String>.from(data['doctorIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'geoPoint': geoPoint,
      'specialties': specialties,
      'facilities': facilities,
      'totalBeds': totalBeds,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isOpen24x7': isOpen24x7,
      'doctorIds': doctorIds,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String? hospitalId;
  final String doctorName;
  final String hospitalName;
  final String date;
  final String slot;
  final int tokenNumber;
  final String status;
  final String bookingType;
  final DateTime timestamp;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.hospitalId,
    required this.doctorName,
    required this.hospitalName,
    required this.date,
    required this.slot,
    required this.tokenNumber,
    required this.status,
    required this.bookingType,
    required this.timestamp,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      hospitalId: data['hospitalId'],
      doctorName: data['doctorName'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      date: data['date'] ?? '',
      slot: data['slot'] ?? '',
      tokenNumber: data['tokenNumber'] ?? 0,
      status: data['status'] ?? 'scheduled',
      bookingType: data['bookingType'] ?? 'CLINIC',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'date': date,
      'slot': slot,
      'tokenNumber': tokenNumber,
      'status': status,
      'bookingType': bookingType,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? hospitalId,
    String? doctorName,
    String? hospitalName,
    String? date,
    String? slot,
    int? tokenNumber,
    String? status,
    String? bookingType,
    DateTime? timestamp,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      hospitalId: hospitalId ?? this.hospitalId,
      doctorName: doctorName ?? this.doctorName,
      hospitalName: hospitalName ?? this.hospitalName,
      date: date ?? this.date,
      slot: slot ?? this.slot,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      status: status ?? this.status,
      bookingType: bookingType ?? this.bookingType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

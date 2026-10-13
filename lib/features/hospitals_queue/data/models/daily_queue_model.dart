import 'package:cloud_firestore/cloud_firestore.dart';

class DailyQueueModel {
  final String id; // format: {doctorId}_{YYYY-MM-DD}
  final int lastTokenIssued;
  final int currentTokenServing;
  final int averageConsultationMinutes;

  DailyQueueModel({
    required this.id,
    required this.lastTokenIssued,
    required this.currentTokenServing,
    required this.averageConsultationMinutes,
  });

  factory DailyQueueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return DailyQueueModel(
      id: doc.id,
      lastTokenIssued: data?['lastTokenIssued'] ?? 0,
      currentTokenServing: data?['currentTokenServing'] ?? 0,
      averageConsultationMinutes: data?['averageConsultationMinutes'] ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastTokenIssued': lastTokenIssued,
      'currentTokenServing': currentTokenServing,
      'averageConsultationMinutes': averageConsultationMinutes,
    };
  }
}

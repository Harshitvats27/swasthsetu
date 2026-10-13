import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swasthsetu/features/appointments/data/models/appointment_model.dart';
import 'package:intl/intl.dart';

class AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;

  AppointmentRemoteDataSource({required this.firestore});

  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    final isOpd = appointment.bookingType == 'OPD';
    final entityId = isOpd && appointment.hospitalId != null && appointment.hospitalId!.isNotEmpty
        ? appointment.hospitalId!
        : appointment.doctorId;
    final docId = '${entityId}_${appointment.date}';
    final dailyQueueRef = firestore.collection('daily_queues').doc(docId);
    final appointmentRef = firestore.collection('appointments').doc();

    final finalToken = await firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(dailyQueueRef);
      int nextToken = 1;

      if (!snapshot.exists) {
        transaction.set(dailyQueueRef, {
          'lastTokenIssued': 1,
          'currentTokenServing': 0,
          'averageConsultationMinutes': 15, // default
        });
      } else {
        final data = snapshot.data();
        nextToken = (data?['lastTokenIssued'] as int? ?? 0) + 1;
        transaction.update(dailyQueueRef, {'lastTokenIssued': nextToken});
      }

      // Also set the appointment doc inside the transaction to ensure atomicity
      final finalAppointment = appointment.copyWith(
        id: appointmentRef.id,
        tokenNumber: nextToken,
      );
      
      transaction.set(appointmentRef, finalAppointment.toMap());

      return nextToken;
    });

    return appointment.copyWith(id: appointmentRef.id, tokenNumber: finalToken);
  }

  Future<List<AppointmentModel>> getUserAppointments(String patientId) async {
    final snapshot = await firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await firestore.collection('appointments').doc(appointmentId).update({
      'status': 'cancelled',
    });
  }
}

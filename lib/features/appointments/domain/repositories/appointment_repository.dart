import 'package:swasthsetu/features/appointments/data/datasources/appointment_remote_datasource.dart';
import 'package:swasthsetu/features/appointments/data/models/appointment_model.dart';

class AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepository({required this.remoteDataSource});

  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    return await remoteDataSource.bookAppointment(appointment);
  }

  Future<List<AppointmentModel>> getUserAppointments(String patientId) async {
    return await remoteDataSource.getUserAppointments(patientId);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await remoteDataSource.cancelAppointment(appointmentId);
  }
}

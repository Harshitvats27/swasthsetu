part of 'appointments_bloc.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserAppointmentsEvent extends AppointmentsEvent {
  final String patientId;

  const LoadUserAppointmentsEvent({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}

class BookAppointmentEvent extends AppointmentsEvent {
  final AppointmentModel appointment;

  const BookAppointmentEvent({required this.appointment});

  @override
  List<Object?> get props => [appointment];
}

class CancelAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;

  const CancelAppointmentEvent({required this.appointmentId});

  @override
  List<Object?> get props => [appointmentId];
}

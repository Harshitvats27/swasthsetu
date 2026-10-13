part of 'appointments_bloc.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentModel> appointments;

  const AppointmentsLoaded({required this.appointments});

  @override
  List<Object?> get props => [appointments];
}

class AppointmentBookingSuccess extends AppointmentsState {
  final AppointmentModel appointment;

  const AppointmentBookingSuccess({required this.appointment});

  @override
  List<Object?> get props => [appointment];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

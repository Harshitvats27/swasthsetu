import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/features/appointments/data/models/appointment_model.dart';
import 'package:swasthsetu/features/appointments/domain/repositories/appointment_repository.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentRepository repository;

  AppointmentsBloc({required this.repository}) : super(const AppointmentsInitial()) {
    on<LoadUserAppointmentsEvent>(_onLoadUserAppointments);
    on<BookAppointmentEvent>(_onBookAppointment);
    on<CancelAppointmentEvent>(_onCancelAppointment);
  }

  Future<void> _onLoadUserAppointments(
      LoadUserAppointmentsEvent event, Emitter<AppointmentsState> emit) async {
    emit(const AppointmentsLoading());
    try {
      final appointments = await repository.getUserAppointments(event.patientId);
      emit(AppointmentsLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentsError(message: e.toString()));
    }
  }

  Future<void> _onBookAppointment(
      BookAppointmentEvent event, Emitter<AppointmentsState> emit) async {
    emit(const AppointmentsLoading());
    try {
      final appointment = await repository.bookAppointment(event.appointment);
      emit(AppointmentBookingSuccess(appointment: appointment));
      // Re-load the appointments for this patient
      add(LoadUserAppointmentsEvent(patientId: appointment.patientId));
    } catch (e) {
      emit(AppointmentsError(message: e.toString()));
    }
  }

  Future<void> _onCancelAppointment(
      CancelAppointmentEvent event, Emitter<AppointmentsState> emit) async {
    try {
      await repository.cancelAppointment(event.appointmentId);
      // We don't have patientId here easily, so the UI should ideally trigger a reload
      // But we can just rely on the UI calling LoadUserAppointmentsEvent after.
    } catch (e) {
      emit(AppointmentsError(message: e.toString()));
    }
  }
}

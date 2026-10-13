import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_event.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_state.dart';
import 'package:swasthsetu/features/doctors/data/repositories/doctor_repository.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRepository repository;

  DoctorBloc({required this.repository}) : super(DoctorInitial()) {
    on<LoadDoctorsEvent>(_onLoadDoctors);
    on<SearchDoctorsEvent>(_onSearchDoctors);
  }

  Future<void> _onLoadDoctors(LoadDoctorsEvent event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    final result = await repository.getDoctors();
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctors) => emit(DoctorLoaded(doctors)),
    );
  }

  Future<void> _onSearchDoctors(SearchDoctorsEvent event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());
    final result = await repository.searchDoctors(event.query);
    result.fold(
      (failure) => emit(DoctorError(failure.message)),
      (doctors) => emit(DoctorLoaded(doctors)),
    );
  }
}

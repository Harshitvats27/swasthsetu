import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_event.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_state.dart';
import 'package:swasthsetu/features/hospitals/data/repositories/hospital_repository.dart';

class HospitalBloc extends Bloc<HospitalEvent, HospitalState> {
  final HospitalRepository repository;

  HospitalBloc({required this.repository}) : super(HospitalInitial()) {
    on<LoadHospitalsEvent>(_onLoadHospitals);
    on<SeedHospitalsEvent>(_onSeedHospitals);
  }

  Future<void> _onLoadHospitals(
      LoadHospitalsEvent event, Emitter<HospitalState> emit) async {
    emit(HospitalLoading());
    final result = await repository.getHospitals();
    result.fold(
      (failure) => emit(HospitalError(failure.message)),
      (hospitals) => emit(HospitalLoaded(hospitals)),
    );
  }

  Future<void> _onSeedHospitals(
      SeedHospitalsEvent event, Emitter<HospitalState> emit) async {
    emit(HospitalLoading());
    final result = await repository.seedHospitals();
    result.fold(
      (failure) => emit(HospitalError(failure.message)),
      (_) => emit(HospitalSeeded()),
    );
  }
}

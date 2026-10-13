import 'package:equatable/equatable.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';

abstract class HospitalState extends Equatable {
  const HospitalState();

  @override
  List<Object?> get props => [];
}

class HospitalInitial extends HospitalState {}

class HospitalLoading extends HospitalState {}

class HospitalLoaded extends HospitalState {
  final List<HospitalModel> hospitals;

  const HospitalLoaded(this.hospitals);

  @override
  List<Object?> get props => [hospitals];
}

class HospitalError extends HospitalState {
  final String message;

  const HospitalError(this.message);

  @override
  List<Object?> get props => [message];
}

class HospitalSeeded extends HospitalState {}

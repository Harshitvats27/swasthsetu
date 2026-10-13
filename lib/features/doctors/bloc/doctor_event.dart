import 'package:equatable/equatable.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorsEvent extends DoctorEvent {}

class SearchDoctorsEvent extends DoctorEvent {
  final String query;

  const SearchDoctorsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

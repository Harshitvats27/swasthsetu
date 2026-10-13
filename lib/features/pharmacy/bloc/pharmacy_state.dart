part of 'pharmacy_bloc.dart';

abstract class PharmacyState extends Equatable {
  const PharmacyState();

  @override
  List<Object?> get props => [];
}

class PharmacyInitial extends PharmacyState {
  const PharmacyInitial();
}

class PharmacyLoading extends PharmacyState {
  const PharmacyLoading();
}

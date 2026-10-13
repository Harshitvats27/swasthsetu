part of 'sos_bloc.dart';

abstract class SosState extends Equatable {
  const SosState();
  
  @override
  List<Object?> get props => [];
}

class SosInitial extends SosState {}

class SosListening extends SosState {}

class SosCountdown extends SosState {
  final int secondsLeft;
  const SosCountdown(this.secondsLeft);
  
  @override
  List<Object?> get props => [secondsLeft];
}

class SosTriggered extends SosState {}

class SosError extends SosState {
  final String message;
  const SosError(this.message);
  
  @override
  List<Object?> get props => [message];
}

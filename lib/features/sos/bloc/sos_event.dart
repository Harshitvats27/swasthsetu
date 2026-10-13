part of 'sos_bloc.dart';

abstract class SosEvent extends Equatable {
  const SosEvent();

  @override
  List<Object?> get props => [];
}

class StartSosListening extends SosEvent {}

class StopSosListening extends SosEvent {}

class TriggerSosEmergency extends SosEvent {}

class CancelSosEmergency extends SosEvent {}

class _TickSosCountdown extends SosEvent {
  final int secondsLeft;
  const _TickSosCountdown(this.secondsLeft);
  
  @override
  List<Object?> get props => [secondsLeft];
}

class _ExecuteSos extends SosEvent {}

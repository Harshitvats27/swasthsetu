part of 'hospitals_queue_bloc.dart';

abstract class HospitalsQueueEvent extends Equatable {
  const HospitalsQueueEvent();

  @override
  List<Object?> get props => [];
}

class SubscribeToQueueEvent extends HospitalsQueueEvent {
  final String doctorId;
  final String date;
  final int userTokenNumber;

  const SubscribeToQueueEvent({
    required this.doctorId,
    required this.date,
    required this.userTokenNumber,
  });

  @override
  List<Object?> get props => [doctorId, date, userTokenNumber];
}

class _QueueUpdatedEvent extends HospitalsQueueEvent {
  final DailyQueueModel queueModel;
  final int userTokenNumber;

  const _QueueUpdatedEvent({
    required this.queueModel,
    required this.userTokenNumber,
  });

  @override
  List<Object?> get props => [queueModel, userTokenNumber];
}

class UnsubscribeFromQueueEvent extends HospitalsQueueEvent {}

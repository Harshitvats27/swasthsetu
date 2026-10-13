part of 'hospitals_queue_bloc.dart';

abstract class HospitalsQueueState extends Equatable {
  const HospitalsQueueState();

  @override
  List<Object?> get props => [];
}

class HospitalsQueueInitial extends HospitalsQueueState {
  const HospitalsQueueInitial();
}

class HospitalsQueueLoading extends HospitalsQueueState {
  const HospitalsQueueLoading();
}

class HospitalsQueueLive extends HospitalsQueueState {
  final DailyQueueModel queueModel;
  final int userTokenNumber;
  
  const HospitalsQueueLive({
    required this.queueModel,
    required this.userTokenNumber,
  });

  int get patientsAhead {
    final ahead = userTokenNumber - queueModel.currentTokenServing;
    // If it's negative, it means your token has already been called
    return ahead > 0 ? ahead - 1 : 0; // -1 because the current token is serving
  }

  int get estimatedWaitTimeMinutes {
    return patientsAhead * queueModel.averageConsultationMinutes;
  }

  bool get isTurnNow => (userTokenNumber == queueModel.currentTokenServing) || (userTokenNumber == queueModel.currentTokenServing + 1);

  @override
  List<Object?> get props => [queueModel, userTokenNumber];
}

class HospitalsQueueError extends HospitalsQueueState {
  final String message;

  const HospitalsQueueError({required this.message});

  @override
  List<Object?> get props => [message];
}

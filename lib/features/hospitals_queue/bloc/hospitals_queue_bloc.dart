import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swasthsetu/features/hospitals_queue/data/models/daily_queue_model.dart';

part 'hospitals_queue_event.dart';
part 'hospitals_queue_state.dart';

class HospitalsQueueBloc extends Bloc<HospitalsQueueEvent, HospitalsQueueState> {
  final FirebaseFirestore firestore;
  StreamSubscription<DocumentSnapshot>? _queueSubscription;

  HospitalsQueueBloc({required this.firestore}) : super(const HospitalsQueueInitial()) {
    on<SubscribeToQueueEvent>(_onSubscribeToQueue);
    on<_QueueUpdatedEvent>(_onQueueUpdated);
    on<UnsubscribeFromQueueEvent>(_onUnsubscribe);
  }

  void _onSubscribeToQueue(SubscribeToQueueEvent event, Emitter<HospitalsQueueState> emit) {
    emit(const HospitalsQueueLoading());
    
    _queueSubscription?.cancel();
    
    final docId = '${event.doctorId}_${event.date}';
    
    _queueSubscription = firestore
        .collection('daily_queues')
        .doc(docId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final queueModel = DailyQueueModel.fromFirestore(snapshot);
        add(_QueueUpdatedEvent(queueModel: queueModel, userTokenNumber: event.userTokenNumber));
      } else {
        // If it doesn't exist, it means no tokens have been issued or it's an error.
        // But since the user has a token, it should exist.
      }
    }, onError: (error) {
      emit(HospitalsQueueError(message: error.toString()));
    });
  }

  void _onQueueUpdated(_QueueUpdatedEvent event, Emitter<HospitalsQueueState> emit) {
    emit(HospitalsQueueLive(
      queueModel: event.queueModel,
      userTokenNumber: event.userTokenNumber,
    ));
  }

  void _onUnsubscribe(UnsubscribeFromQueueEvent event, Emitter<HospitalsQueueState> emit) {
    _queueSubscription?.cancel();
    emit(const HospitalsQueueInitial());
  }

  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    return super.close();
  }
}

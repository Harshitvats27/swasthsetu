import 'package:get_it/get_it.dart';
import 'package:swasthsetu/features/hospitals_queue/bloc/hospitals_queue_bloc.dart';

void hospitalsQueueInjection(GetIt sl) {
  // BLoC
  sl.registerFactory(() => HospitalsQueueBloc(firestore: sl()));
}

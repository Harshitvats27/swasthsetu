import 'package:get_it/get_it.dart';
import 'package:swasthsetu/features/appointments/bloc/appointments_bloc.dart';
import 'package:swasthsetu/features/appointments/data/datasources/appointment_remote_datasource.dart';
import 'package:swasthsetu/features/appointments/domain/repositories/appointment_repository.dart';

void appointmentsInjection(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSource(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepository(remoteDataSource: sl()),
  );

  // BLoC
  sl.registerFactory(() => AppointmentsBloc(repository: sl()));
}

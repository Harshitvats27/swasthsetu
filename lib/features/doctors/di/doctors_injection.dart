import 'package:get_it/get_it.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_bloc.dart';
import 'package:swasthsetu/features/doctors/data/datasources/doctor_remote_datasource.dart';
import 'package:swasthsetu/features/doctors/data/repositories/doctor_repository.dart';

void doctorsInjection(GetIt sl) {
  // Blocs
  sl.registerFactory(() => DoctorBloc(repository: sl()));

  // Repositories
  sl.registerLazySingleton(() => DoctorRepository(remote: sl()));

  // Data sources
  sl.registerLazySingleton(() => DoctorRemoteDataSource(firestore: sl()));
}

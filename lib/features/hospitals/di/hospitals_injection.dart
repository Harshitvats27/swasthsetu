import 'package:get_it/get_it.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_bloc.dart';
import 'package:swasthsetu/features/hospitals/data/datasources/hospital_remote_datasource.dart';
import 'package:swasthsetu/features/hospitals/data/repositories/hospital_repository.dart';

void hospitalsInjection(GetIt sl) {
  // Blocs
  sl.registerFactory(() => HospitalBloc(repository: sl()));

  // Repositories
  sl.registerLazySingleton(() => HospitalRepository(remote: sl()));

  // Data sources
  sl.registerLazySingleton(() => HospitalRemoteDataSource(firestore: sl()));
}

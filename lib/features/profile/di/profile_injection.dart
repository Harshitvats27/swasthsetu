import 'package:get_it/get_it.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';
import 'package:swasthsetu/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:swasthsetu/features/profile/data/repositories/profile_repository.dart';
import 'package:swasthsetu/features/profile/data/repositories/profile_repository_impl.dart';

void profileInjection(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remote: sl()),
  );

  // BLoC
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(repository: sl()),
  );
}

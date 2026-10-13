import 'package:get_it/get_it.dart';

import 'package:swasthsetu/features/sos/bloc/sos_bloc.dart';

/// Registers all [SOS Emergency] dependencies into [sl].
void sosInjection(GetIt sl) {
  // BLoC
  sl.registerLazySingleton<SosBloc>(() => SosBloc());
  // Repositories
  // Use-cases
}

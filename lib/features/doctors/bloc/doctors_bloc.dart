import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'doctors_event.dart';
part 'doctors_state.dart';

/// BLoC for the doctors feature.
class DoctorsBloc extends Bloc<DoctorsEvent, DoctorsState> {
  DoctorsBloc() : super(const DoctorsInitial()) {
    // Register event handlers here
  }
}

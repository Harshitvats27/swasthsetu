import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pharmacy_event.dart';
part 'pharmacy_state.dart';

/// BLoC for the pharmacy feature.
class PharmacyBloc extends Bloc<PharmacyEvent, PharmacyState> {
  PharmacyBloc() : super(const PharmacyInitial()) {
    // Register event handlers here
  }
}

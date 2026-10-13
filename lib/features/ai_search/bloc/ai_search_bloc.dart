import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ai_search_event.dart';
part 'ai_search_state.dart';

/// BLoC for the ai_search feature.
class AiSearchBloc extends Bloc<AiSearchEvent, AiSearchState> {
  AiSearchBloc() : super(const AiSearchInitial()) {
    // Register event handlers here
  }
}

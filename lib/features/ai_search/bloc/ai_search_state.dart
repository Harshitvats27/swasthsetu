part of 'ai_search_bloc.dart';

abstract class AiSearchState extends Equatable {
  const AiSearchState();

  @override
  List<Object?> get props => [];
}

class AiSearchInitial extends AiSearchState {
  const AiSearchInitial();
}

class AiSearchLoading extends AiSearchState {
  const AiSearchLoading();
}

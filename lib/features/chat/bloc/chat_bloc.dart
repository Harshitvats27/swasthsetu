import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// BLoC for the chat feature.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatInitial()) {
    // Register event handlers here
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import 'assistant_event.dart';
import 'assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final AssistantRepository _repository;

  /// Goes up on every reset, so a reply that arrives after the user
  /// tapped "New chat" is ignored instead of landing in the new chat.
  int _conversationId = 0;

  AssistantBloc(this._repository) : super(const AssistantState()) {
    on<AssistantMessageSent>(_onMessageSent);
    on<AssistantReset>(_onReset);
  }

  Future<void> _onMessageSent(
    AssistantMessageSent event,
    Emitter<AssistantState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty || state.isSending) return;

    final conversationId = _conversationId;

    // Show the user's message straight away
    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.user, text: text),
        ],
        isSending: true,
      ),
    );

    try {
      final reply = await _repository.sendMessage(text);
      if (conversationId != _conversationId) return;

      emit(
        state.copyWith(messages: [...state.messages, reply], isSending: false),
      );
    } catch (_) {
      if (conversationId != _conversationId) return;

      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'The assistant couldn\'t reply. Check your connection and try again.',
        ),
      );
    }
  }

  void _onReset(AssistantReset event, Emitter<AssistantState> emit) {
    _conversationId++;
    _repository.reset();
    emit(const AssistantState());
  }
}

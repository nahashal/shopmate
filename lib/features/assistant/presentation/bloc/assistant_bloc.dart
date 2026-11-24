import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/failures/assistant_failure.dart';
import '../../domain/repositories/assistant_repository.dart';
import 'assistant_event.dart';
import 'assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final AssistantRepository _repository;

  /// Goes up on every reset, so a reply that arrives after the user
  /// tapped "New chat" is ignored instead of landing in the new chat.
  int _conversationId = 0;

  AssistantBloc(this._repository) : super(const AssistantState()) {
    on<AssistantStarted>(_onStarted);
    on<AssistantMessageSent>(_onMessageSent);
    on<AssistantReset>(_onReset);
  }

  void _onStarted(AssistantStarted event, Emitter<AssistantState> emit) {
    // Start loading in the background; don't wait for it
    _repository.warmUp();
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

    var replyShown = false;

    try {
      await for (final reply in _repository.sendMessage(text)) {
        if (emit.isDone || conversationId != _conversationId) return;

        // Replace the growing reply each time new text arrives
        final previous = replyShown
            ? state.messages.sublist(0, state.messages.length - 1)
            : state.messages;

        emit(state.copyWith(messages: [...previous, reply], isSending: true));
        replyShown = true;
      }

      if (emit.isDone || conversationId != _conversationId) return;
      emit(state.copyWith(isSending: false));
    } catch (error, stackTrace) {
      debugPrint('ASSISTANT ERROR: $error');
      debugPrint('$stackTrace');

      if (emit.isDone || conversationId != _conversationId) return;

      // Remove a half-finished reply if the stream broke midway
      final messages = replyShown
          ? state.messages.sublist(0, state.messages.length - 1)
          : state.messages;

      emit(
        state.copyWith(
          messages: messages,
          isSending: false,
          errorMessage: error is AssistantBusyFailure
              ? 'The assistant is busy right now. Please try again in a moment.'
              : kDebugMode
              ? 'Assistant error: $error'
              : 'The assistant couldn\'t reply. Check your connection and try again.',
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

import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

class AssistantState extends Equatable {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  const AssistantState({
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isSending, errorMessage];
}

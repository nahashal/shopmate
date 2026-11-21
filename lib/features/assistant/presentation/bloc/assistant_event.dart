import 'package:equatable/equatable.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object?> get props => [];
}

class AssistantMessageSent extends AssistantEvent {
  final String text;

  const AssistantMessageSent(this.text);

  @override
  List<Object?> get props => [text];
}

/// Clears the chat and starts a new conversation.
class AssistantReset extends AssistantEvent {
  const AssistantReset();
}

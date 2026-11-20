import '../entities/chat_message.dart';

abstract class AssistantRepository {
  /// Sends the user's message and returns the assistant's reply.
  /// The conversation is remembered between calls.
  Future<ChatMessage> sendMessage(String text);

  /// Forgets the conversation and starts fresh.
  void reset();
}

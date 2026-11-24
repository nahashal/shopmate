import '../entities/chat_message.dart';

abstract class AssistantRepository {
  /// Loads the product catalog and prepares the chat in the background,
  /// so the first message doesn't have to wait for it.
  Future<void> warmUp();

  /// Streams the assistant's reply as it is written.
  /// Each emitted message contains the text so far; the last one
  /// also contains the recommended products.
  Stream<ChatMessage> sendMessage(String text);

  /// Forgets the conversation and starts fresh.
  void reset();
}

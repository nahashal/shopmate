/// Thrown when Gemini is overloaded or rate-limited, even after retrying.
class AssistantBusyFailure implements Exception {
  const AssistantBusyFailure();

  @override
  String toString() => 'The assistant is busy right now.';
}

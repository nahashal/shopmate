import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  final ChatRole role;
  final String text;

  /// Products the assistant recommended, shown as tappable cards.
  final List<Product> products;

  const ChatMessage({
    required this.role,
    required this.text,
    this.products = const [],
  });

  bool get isUser => role == ChatRole.user;

  @override
  List<Object?> get props => [role, text, products];
}

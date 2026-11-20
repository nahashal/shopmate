import 'package:dio/dio.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  static const _modelName = 'gemini-3.5-flash';
  static const _maxProducts = 4;

  /// Matches product IDs the model writes like [[12]]
  static final _idPattern = RegExp(r'\[\[(\d+)\]\]');

  final Dio _dio;
  ChatSession? _chat;

  AssistantRepositoryImpl(this._dio);

  @override
  Future<ChatMessage> sendMessage(String text) async {
    // The chat is created on the first message, so the catalog
    // is only downloaded when someone actually uses the assistant.
    final chat = _chat ??= await _startChat();

    final response = await chat.sendMessage(Content.text(text));
    final reply = response.text ?? '';

    // 1. Collect the product IDs the model mentioned
    final ids = _idPattern
        .allMatches(reply)
        .map((match) => int.parse(match.group(1)!))
        .toSet()
        .take(_maxProducts)
        .toList();

    // 2. Remove the [[id]] markers from the text the user sees
    final cleanText = reply
        .replaceAll(_idPattern, '')
        .replaceAllMapped(RegExp(r' +([.,!?])'), (m) => m.group(1)!)
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();

    // 3. Load the full products so they can be shown as cards
    final products = await _fetchProducts(ids);

    return ChatMessage(
      role: ChatRole.assistant,
      text: cleanText.isEmpty ? 'Here is what I found:' : cleanText,
      products: products,
    );
  }

  @override
  void reset() => _chat = null;

  Future<ChatSession> _startChat() async {
    final catalog = await _loadCatalog();

    final model = FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_buildInstructions(catalog)),
    );

    return model.startChat();
  }

  /// A compact list of every product: one short line each.
  Future<String> _loadCatalog() async {
    final response = await _dio.get(
      '/products',
      queryParameters: {
        'limit': 0, // 0 = all products
        'select': 'title,category,price,rating',
      },
    );

    final products = (response.data['products'] as List).map(
      (item) => Map<String, dynamic>.from(item as Map),
    );

    return products
        .map(
          (p) =>
              '${p['id']} | ${p['title']} | ${p['category']} | '
              '\$${p['price']} | ${p['rating']}',
        )
        .join('\n');
  }

  String _buildInstructions(String catalog) {
    return '''
You are ShopMate Assistant, a friendly shopping helper inside the ShopMate app.

Rules:
- Only recommend products from the catalog below. Never invent products.
- When you mention a product, write its id in double brackets right after its name, for example: Essence Mascara Lash Princess [[1]].
- Recommend at most $_maxProducts products per reply.
- Prices are in US dollars.
- Keep replies short (under 120 words), in plain text with no markdown.
- If nothing in the catalog fits, say so honestly and suggest something close.
- If the question is not about shopping, politely steer back to helping them shop.

Catalog (id | title | category | price | rating):
$catalog
''';
  }

  Future<List<Product>> _fetchProducts(List<int> ids) async {
    final results = await Future.wait(
      ids.map((id) async {
        try {
          final response = await _dio.get('/products/$id');
          return ProductModel.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
        } catch (_) {
          return null; // Skip a product that fails to load
        }
      }),
    );

    return results.whereType<Product>().toList();
  }
}

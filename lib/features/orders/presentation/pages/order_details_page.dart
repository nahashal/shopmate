import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_request.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_state.dart';
import '../utils/order_formatters.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_thumbnail.dart';
import 'order_request_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final ShopOrder order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        // Use the live copy from Firestore; fall back to the one passed in
        final current =
            state.orders.where((o) => o.id == order.id).firstOrNull ?? order;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Order #${shortOrderId(current.id)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Status and date
              _Card(
                child: Row(
                  children: [
                    OrderStatusChip(status: current.status),
                    const Spacer(),
                    Text(
                      formatOrderDate(current.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Cancel / return / exchange details
              if (current.request != null) ...[
                const SizedBox(height: 20),
                _SectionTitle(current.request!.type.heading),
                _RequestCard(request: current.request!),
              ],
              const SizedBox(height: 20),

              // Items
              const _SectionTitle('Items'),
              _Card(
                child: Column(
                  children: [
                    for (final item in current.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            OrderThumbnail(
                              imageUrl: item.product.thumbnail,
                              size: 56,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.quantity} × '
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Delivery address
              const _SectionTitle('Delivery address'),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.address.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.address.formatted,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.address.phone,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment and totals
              const _SectionTitle('Payment'),
              _Card(
                child: Column(
                  children: [
                    _row('Method', current.paymentMethod),
                    const Divider(height: 24),
                    _row(
                      'Subtotal',
                      '\$${current.subtotal.toStringAsFixed(2)}',
                    ),
                    _row(
                      'Shipping',
                      current.shippingFee == 0
                          ? 'Free'
                          : '\$${current.shippingFee.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 4),
                    _row(
                      'Total',
                      '\$${current.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildActions(context, current),
        );
      },
    );
  }

  Widget? _buildActions(BuildContext context, ShopOrder order) {
    if (order.canCancel) {
      return _ActionBar(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _openRequest(context, order, OrderRequestType.cancel),
              icon: const Icon(Icons.close),
              label: const Text('Cancel order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ],
      );
    }

    if (order.canReturnOrExchange) {
      return _ActionBar(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _openRequest(context, order, OrderRequestType.returnOrder),
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('Return'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _openRequest(context, order, OrderRequestType.exchange),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Exchange'),
            ),
          ),
        ],
      );
    }

    return null; // No actions for other statuses
  }

  Future<void> _openRequest(
    BuildContext context,
    ShopOrder order,
    OrderRequestType type,
  ) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OrderRequestPage(order: order, type: type),
      ),
    );

    if (done == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(type.successMessage)));
    }
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final OrderRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reason',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            request.reason,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (request.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Comment',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              request.comment,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Requested on ${formatOrderDate(request.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final List<Widget> children;

  const _ActionBar({required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(height: 52, child: Row(children: children)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

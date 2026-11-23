import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../utils/order_formatters.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_thumbnail.dart';
import 'order_details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user?.id ?? '';

    return BlocProvider(
      create: (_) => getIt<OrdersBloc>()..add(OrdersStarted(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My orders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            switch (state.status) {
              case OrdersStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );

              case OrdersStatus.failure:
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Something went wrong.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                );

              case OrdersStatus.loaded:
                if (state.orders.isEmpty) return const _EmptyOrders();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _OrderCard(order: state.orders[index]);
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ShopOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final extraItems = order.items.length - 3;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final ordersBloc = context.read<OrdersBloc>();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: ordersBloc,
                child: OrderDetailsPage(order: order),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Order #${shortOrderId(order.id)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formatOrderDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Up to 3 product images, then "+N"
              Row(
                children: [
                  for (final item in order.items.take(3))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OrderThumbnail(imageUrl: item.product.thumbnail),
                    ),
                  if (extraItems > 0)
                    Text(
                      '+$extraItems',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),

              Row(
                children: [
                  Text(
                    '${order.itemCount} '
                    '${order.itemCount == 1 ? 'item' : 'items'}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your orders will appear here after checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

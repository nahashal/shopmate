import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final cartBloc = context.read<CartBloc>();
    final atMax = item.quantity >= product.stock;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cartBloc.add(CartItemRemoved(product.id)),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity controls and line total
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => cartBloc.add(
                        CartQuantityChanged(
                          productId: product.id,
                          quantity: item.quantity - 1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: atMax
                          ? null
                          : () => cartBloc.add(
                              CartQuantityChanged(
                                productId: product.id,
                                quantity: item.quantity + 1,
                              ),
                            ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? AppColors.textSecondary.withValues(alpha: 0.4)
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}

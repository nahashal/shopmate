import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ShopMateBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final int cartCount;

  const ShopMateBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.cartCount = 0,
  });

  static const List<IconData> icons = [
    Icons.home_outlined,
    Icons.shopping_cart_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  static const List<String> labels = ['Home', 'Cart', 'Favourites', 'Profile'];

  static const int cartIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isSelected = selectedIndex == index;

            Widget icon = Icon(
              icons[index],
              color: AppColors.textPrimary,
              size: 23,
            );

            // Badge only on the Cart icon
            if (index == cartIndex) {
              icon = Badge(
                isLabelVisible: cartCount > 0,
                backgroundColor: AppColors.primaryDark,
                textColor: Colors.white,
                label: Text(cartCount > 99 ? '99+' : '$cartCount'),
                child: icon,
              );
            }

            return GestureDetector(
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    icon,
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        labels[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

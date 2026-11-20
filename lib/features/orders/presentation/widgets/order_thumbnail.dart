import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OrderThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;

  const OrderThumbnail({super.key, required this.imageUrl, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

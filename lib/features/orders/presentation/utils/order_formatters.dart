import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// e.g. "20 Nov 2026, 5:19 PM"
String formatOrderDate(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  return '${date.day} ${_months[date.month - 1]} ${date.year}, '
      '$hour:$minute $period';
}

/// First 8 characters in capitals, e.g. "K3F9X2QA"
String shortOrderId(String id) {
  return (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();
}

String orderStatusLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.placed => 'Placed',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
    OrderStatus.returnRequested => 'Return requested',
    OrderStatus.returned => 'Returned',
    OrderStatus.exchangeRequested => 'Exchange requested',
    OrderStatus.exchanged => 'Exchanged',
  };
}

Color orderStatusColor(OrderStatus status) {
  return switch (status) {
    OrderStatus.placed => AppColors.primaryDark,
    OrderStatus.shipped => Colors.blue,
    OrderStatus.delivered => Colors.green,
    OrderStatus.cancelled => Colors.red,
    OrderStatus.returnRequested => Colors.orange,
    OrderStatus.returned => Colors.blueGrey,
    OrderStatus.exchangeRequested => Colors.deepPurple,
    OrderStatus.exchanged => Colors.teal,
  };
}

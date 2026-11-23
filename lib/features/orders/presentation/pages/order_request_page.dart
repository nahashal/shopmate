import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_request.dart';
import '../bloc/order_request_bloc.dart';
import '../bloc/order_request_event.dart';
import '../bloc/order_request_state.dart';
import '../utils/order_formatters.dart';

class OrderRequestPage extends StatelessWidget {
  final ShopOrder order;
  final OrderRequestType type;

  const OrderRequestPage({super.key, required this.order, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderRequestBloc>(),
      child: _OrderRequestView(order: order, type: type),
    );
  }
}

class _OrderRequestView extends StatefulWidget {
  final ShopOrder order;
  final OrderRequestType type;

  const _OrderRequestView({required this.order, required this.type});

  @override
  State<_OrderRequestView> createState() => _OrderRequestViewState();
}

class _OrderRequestViewState extends State<_OrderRequestView> {
  final _commentController = TextEditingController();

  String? _reason;
  String? _commentError;

  bool get _isOther => _reason == OrderRequest.otherReason;
  bool get _isCancel => widget.type == OrderRequestType.cancel;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final reason = _reason;
    if (reason == null) return;

    final comment = _commentController.text.trim();
    if (_isOther && comment.isEmpty) {
      setState(() => _commentError = 'Please tell us the reason');
      return;
    }

    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    context.read<OrderRequestBloc>().add(
      OrderRequestSubmitted(
        userId: userId,
        orderId: widget.order.id,
        request: OrderRequest(
          type: widget.type,
          reason: reason,
          comment: comment,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final type = widget.type;

    return BlocListener<OrderRequestBloc, OrderRequestState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OrderRequestStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == OrderRequestStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            type.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Which order this is about
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Order #${shortOrderId(order.id)} · '
                      '${order.itemCount} '
                      '${order.itemCount == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              type.question,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Reason options
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final reason in type.reasons)
                    _ReasonTile(
                      label: reason,
                      selected: _reason == reason,
                      onTap: () => setState(() {
                        _reason = reason;
                        _commentError = null;
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Comment (required only for "Other")
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_commentError != null) {
                  setState(() => _commentError = null);
                }
              },
              decoration: InputDecoration(
                labelText: _isOther
                    ? 'Tell us more (required)'
                    : 'Tell us more (optional)',
                alignLabelWithHint: true,
                errorText: _commentError,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // What happens next
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      type.note,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: BlocBuilder<OrderRequestBloc, OrderRequestState>(
              builder: (context, state) {
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _reason == null || state.isSubmitting
                        ? null
                        : _submit,
                    style: _isCancel
                        ? ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          )
                        : null,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            _reason == null
                                ? 'Choose a reason'
                                : type.submitLabel,
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

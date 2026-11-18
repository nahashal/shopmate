import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../domain/entities/shipping_address.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // A fresh CheckoutBloc for this screen only
    return BlocProvider(
      create: (_) => getIt<CheckoutBloc>(),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  static const _paymentMethod = 'Cash on delivery';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinController = TextEditingController();

  late final List<CartItem> _items;

  @override
  void initState() {
    super.initState();

    // Take a copy of the cart when checkout opens
    _items = List.of(context.read<CartBloc>().state.items);

    // Pre-fill the name from the signed-in user
    final user = context.read<AuthBloc>().state.user;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.total);

  void _placeOrder() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    context.read<CheckoutBloc>().add(
      CheckoutSubmitted(
        userId: userId,
        items: _items,
        address: ShippingAddress(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine: _addressController.text.trim(),
          city: _cityController.text.trim(),
          pinCode: _pinController.text.trim(),
        ),
        paymentMethod: _paymentMethod,
      ),
    );
  }

  // Validators
  String? _required(String? value, String field) {
    if ((value ?? '').trim().isEmpty) return 'Enter your $field';
    return null;
  }

  String? _phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a 10-digit phone number';
    return null;
  }

  String? _pin(String? value) {
    if (!RegExp(r'^\d{6}$').hasMatch((value ?? '').trim())) {
      return 'Enter a 6-digit PIN';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CheckoutStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderSuccessPage(orderId: state.orderId!),
            ),
          );
        } else if (state.status == CheckoutStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Checkout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _SectionTitle('Shipping address'),
              AuthTextField(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: (value) => _required(value, 'name'),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _phoneController,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _phone,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _addressController,
                label: 'House, street, area',
                icon: Icons.home_outlined,
                keyboardType: TextInputType.streetAddress,
                validator: (value) => _required(value, 'address'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AuthTextField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      validator: (value) => _required(value, 'city'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AuthTextField(
                      controller: _pinController,
                      label: 'PIN',
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: _pin,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const _SectionTitle('Payment'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.payments_outlined, color: AppColors.primaryDark),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _paymentMethod,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pay when your order arrives',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppColors.primaryDark),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const _SectionTitle('Order summary'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (final item in _items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.title} × ${item.quantity}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 24),
                    _summaryRow(
                      'Subtotal',
                      '\$${_subtotal.toStringAsFixed(2)}',
                    ),
                    _summaryRow('Shipping', 'Free'),
                    const SizedBox(height: 4),
                    _summaryRow(
                      'Total',
                      '\$${_subtotal.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : _placeOrder,
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            'Place order · \$${_subtotal.toStringAsFixed(2)}',
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

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

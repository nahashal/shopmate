import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/widgets/auth_text_field.dart';
import '../../../orders/domain/entities/shipping_address.dart';
import '../../domain/entities/saved_address.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../utils/address_validators.dart';

class AddressFormPage extends StatefulWidget {
  /// Pass an address to edit it; leave null to add a new one.
  final SavedAddress? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  static const _labels = ['Home', 'Work', 'Other'];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinController = TextEditingController();

  String _label = 'Home';
  bool _isDefault = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.address;
    if (existing != null) {
      _label = existing.label;
      _isDefault = existing.isDefault;
      _nameController.text = existing.address.fullName;
      _phoneController.text = existing.address.phone;
      _addressController.text = existing.address.addressLine;
      _cityController.text = existing.address.city;
      _pinController.text = existing.address.pinCode;
    } else {
      final user = context.read<AuthBloc>().state.user;
      _nameController.text = user?.displayName ?? '';
    }
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

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final saved = SavedAddress(
      id: widget.address?.id ?? '',
      label: _label,
      isDefault: _isDefault,
      address: ShippingAddress(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        pinCode: _pinController.text.trim(),
      ),
    );

    context.read<AddressBloc>().add(AddressSaved(saved));

    // Firestore applies the change on the phone straight away,
    // so we can close the form without waiting.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit address' : 'Add address',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final label in _labels)
                  ChoiceChip(
                    label: Text(label),
                    selected: _label == label,
                    onSelected: (_) => setState(() => _label = label),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              validator: (v) => AddressValidators.required(v, 'name'),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _phoneController,
              label: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: AddressValidators.phone,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _addressController,
              label: 'House, street, area',
              icon: Icons.home_outlined,
              keyboardType: TextInputType.streetAddress,
              validator: (v) => AddressValidators.required(v, 'address'),
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
                    validator: (v) => AddressValidators.required(v, 'city'),
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
                    validator: AddressValidators.pin,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              child: SwitchListTile(
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                activeTrackColor: AppColors.primary,
                title: const Text(
                  'Set as default address',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Used automatically at checkout'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Save changes' : 'Save address'),
            ),
          ),
        ),
      ),
    );
  }
}

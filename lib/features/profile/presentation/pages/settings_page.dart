import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage) ||
          (current.infoMessage != null &&
              previous.infoMessage != current.infoMessage),
      listener: (context, state) {
        final message = state.errorMessage ?? state.infoMessage!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final user = state.user;
        final name = (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim()
            : 'Not set';
        final email = user?.email ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: state.isSubmitting
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _SectionTitle('Account'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Name',
                    subtitle: name,
                    onTap: state.isSubmitting
                        ? null
                        : () => _editName(context, user?.displayName ?? ''),
                  ),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: email,
                    showChevron: false,
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change password',
                    subtitle: 'We\'ll email you a reset link',
                    onTap: state.isSubmitting || email.isEmpty
                        ? null
                        : () => _confirmPasswordReset(context, email),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle('App'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About ShopMate',
                    subtitle: 'Version $_appVersion',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editName(BuildContext context, String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: currentName),
    );

    if (newName != null && newName != currentName.trim() && context.mounted) {
      context.read<AuthBloc>().add(AuthDisplayNameUpdateRequested(newName));
    }
  }

  Future<void> _confirmPasswordReset(BuildContext context, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change password?'),
        content: Text(
          'We\'ll send a link to $email. '
          'Open it to choose a new password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Send link'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthPasswordResetRequested(email));
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ShopMate',
      applicationVersion: 'Version $_appVersion',
      applicationIcon: const CircleAvatar(
        backgroundColor: AppColors.cream,
        child: Icon(Icons.shopping_bag_outlined, color: AppColors.primaryDark),
      ),
      children: const [
        Text(
          'A Flutter e-commerce app built with BLoC, Firebase '
          'and a Gemini-powered shopping assistant.',
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initialName;

  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit name'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
          decoration: const InputDecoration(labelText: 'Full name'),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? 'Enter your name' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, indent: 56, color: AppColors.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
    );
  }
}

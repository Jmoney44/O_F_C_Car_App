import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config.dart';
import '../../core/validators.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../auth/auth_screens.dart';
import '../cars/car_details_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final repositories = ref.watch(repositoriesProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 28,
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              user.name.isEmpty ? 'OFC customer' : user.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(user.email),
            trailing: IconButton(
              tooltip: 'Edit profile',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/account/edit'),
            ),
          ),
          if (repositories.isDemo)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DemoNotice(),
            ),
          if (user.isAdmin)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Admin area'),
                  subtitle: const Text('Stock, QR codes, orders and offers'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin'),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('My orders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/orders'),
          ),
          ListTile(
            leading: const Icon(Icons.handshake_outlined),
            title: const Text('My offers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/offers'),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: const Text('Call the showroom'),
            subtitle: const Text(AppConfig.showroomPhone),
            onTap: () => callShowroom(context),
          ),
          const ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Visit us'),
            subtitle: Text(AppConfig.showroomAddress),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sign out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => runGuarded(context, repositories.auth.signOut),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: ref.read(currentUserProvider).value?.name ?? '',
  );
  late final _phone = TextEditingController(
    text: ref.read(currentUserProvider).value?.phone ?? '',
  );
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await runGuarded(
      context,
      () => ref
          .read(repositoriesProvider)
          .auth
          .updateProfile(name: _name.text.trim(), phone: _phone.text.trim()),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      showMessage(context, 'Profile updated');
      context.pop();
    }
  }

  Future<void> _resetPassword() async {
    final email = ref.read(currentUserProvider).value?.email;
    if (email == null) return;
    final ok = await runGuarded(
      context,
      () => ref.read(repositoriesProvider).auth.sendPasswordReset(email),
    );
    if (ok && mounted) {
      showMessage(context, 'A link to change your password was sent to $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              validator: (value) => Validators.required(value, 'Full name'),
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),
            LoadingButton(label: 'Save', loading: _loading, onPressed: _save),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _resetPassword,
              child: const Text('Email me a link to change my password'),
            ),
          ],
        ),
      ),
    );
  }
}

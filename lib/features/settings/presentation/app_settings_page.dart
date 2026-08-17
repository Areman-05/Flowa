import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../lock/presentation/pin_lock_pages.dart';
import '../../notifications/presentation/notification_settings_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _balanceHidden = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hidden = await FlowaServices.preferencesRepository
        .isBalanceHiddenByDefault();
    if (!mounted) {
      return;
    }
    setState(() {
      _balanceHidden = hidden;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Hide balance by default'),
                  subtitle: const Text(
                    'Start Home with Available Balance masked',
                  ),
                  value: _balanceHidden,
                  onChanged: (value) async {
                    setState(() => _balanceHidden = value);
                    await FlowaServices.preferencesRepository
                        .setBalanceHiddenByDefault(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Notification preferences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const NotificationSettingsPage(),
                  ),
                ),
                ListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('App lock'),
                  subtitle: const Text('Require a 4-digit PIN on launch'),
                  trailing: const Icon(Icons.lock_outline),
                  onTap: () =>
                      pushFlowaRoute<void>(context, const PinSetupPage()),
                ),
                Padding(
                  padding: FlowaSpacing.screenPadding,
                  child: FlowaSecondaryButton(
                    label: 'Replay onboarding',
                    onPressed: () async {
                      // Kept simple: mark incomplete and ask user to restart app.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Onboarding will show again on next cold start after reset.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

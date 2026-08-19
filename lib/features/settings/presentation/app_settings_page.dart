import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../lock/presentation/pin_lock_pages.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import 'about_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _balanceHidden = true;
  bool _budgetEnabled = false;
  double _budgetLimit = 500;
  bool _darkMode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hidden =
        await FlowaServices.preferencesRepository.isBalanceHiddenByDefault();
    final budgetEnabled =
        await FlowaServices.preferencesRepository.isBudgetEnabled();
    final budgetLimit =
        await FlowaServices.preferencesRepository.getMonthlyBudgetLimit();
    final dark =
        await FlowaServices.preferencesRepository.isDarkModeEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _balanceHidden = hidden;
      _budgetEnabled = budgetEnabled;
      _budgetLimit = budgetLimit;
      _darkMode = dark;
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
                SwitchListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Dark mode'),
                  subtitle: const Text('Switch to dark colour scheme'),
                  value: _darkMode,
                  onChanged: (value) async {
                    setState(() => _darkMode = value);
                    await FlowaServices.preferencesRepository
                        .setDarkModeEnabled(value);
                  },
                ),
                SwitchListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Monthly budget target'),
                  subtitle: const Text(
                    'Track spending against a cap in Insights',
                  ),
                  value: _budgetEnabled,
                  onChanged: (value) async {
                    setState(() => _budgetEnabled = value);
                    await FlowaServices.preferencesRepository
                        .setBudgetEnabled(value);
                  },
                ),
                if (_budgetEnabled)
                  ListTile(
                    contentPadding: FlowaSpacing.screenPadding,
                    title: const Text('Budget limit'),
                    subtitle: Text('\$${_budgetLimit.toStringAsFixed(0)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final controller = TextEditingController(
                        text: _budgetLimit.toStringAsFixed(0),
                      );
                      final next = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Monthly budget'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: '\$ ',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final value =
                                      double.tryParse(controller.text) ?? 0;
                                  Navigator.pop(context, value);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );
                      if (next != null && next > 0) {
                        setState(() => _budgetLimit = next);
                        await FlowaServices.preferencesRepository
                            .setMonthlyBudgetLimit(next);
                      }
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
                const Divider(height: 1),
                ListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('About Flowa'),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () =>
                      pushFlowaRoute<void>(context, const AboutPage()),
                ),
                Padding(
                  padding: FlowaSpacing.screenPadding,
                  child: FlowaSecondaryButton(
                    label: 'Replay onboarding',
                    onPressed: () async {
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

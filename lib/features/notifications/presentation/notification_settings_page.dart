import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/repositories/preferences_repository.dart';

/// Granular notification preferences to reduce notification fatigue.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _loading = true;
  bool _allowNotifications = true;
  bool _transactionNotifications = true;
  bool _marketingPromotions = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs =
        await FlowaServices.preferencesRepository.getNotificationPreferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _allowNotifications = prefs.allowNotifications;
      _transactionNotifications = prefs.transactionNotifications;
      _marketingPromotions = prefs.marketingNotifications;
      _loading = false;
    });
  }

  Future<void> _persist() {
    return FlowaServices.preferencesRepository.saveNotificationPreferences(
      NotificationPreferences(
        allowNotifications: _allowNotifications,
        transactionNotifications: _transactionNotifications,
        marketingNotifications: _marketingPromotions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Allow Notifications'),
                  value: _allowNotifications,
                  onChanged: (value) async {
                    setState(() {
                      _allowNotifications = value;
                      if (!value) {
                        _transactionNotifications = false;
                        _marketingPromotions = false;
                      }
                    });
                    await _persist();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Transaction Notifications'),
                  subtitle: const Text(
                    'Get notified when transactions are processed',
                  ),
                  value: _allowNotifications && _transactionNotifications,
                  onChanged: !_allowNotifications
                      ? null
                      : (value) async {
                          setState(() => _transactionNotifications = value);
                          await _persist();
                        },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: FlowaSpacing.screenPadding,
                  title: const Text('Marketing and Promotions'),
                  subtitle: const Text(
                    'Receive updates on new features, offers, and promotions',
                  ),
                  value: _allowNotifications && _marketingPromotions,
                  onChanged: !_allowNotifications
                      ? null
                      : (value) async {
                          setState(() => _marketingPromotions = value);
                          await _persist();
                        },
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../design_system/tokens/flowa_spacing.dart';

/// Granular notification preferences to reduce notification fatigue.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _allowNotifications = true;
  bool _transactionNotifications = true;
  bool _marketingPromotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: ListView(
        children: [
          SwitchListTile(
            contentPadding: FlowaSpacing.screenPadding,
            title: const Text('Allow Notifications'),
            value: _allowNotifications,
            onChanged: (value) {
              setState(() {
                _allowNotifications = value;
                if (!value) {
                  _transactionNotifications = false;
                  _marketingPromotions = false;
                }
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: FlowaSpacing.screenPadding,
            title: const Text('Transaction Notifications'),
            subtitle: const Text('Get notified when transactions are processed'),
            value: _allowNotifications && _transactionNotifications,
            onChanged: !_allowNotifications
                ? null
                : (value) {
                    setState(() => _transactionNotifications = value);
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
                : (value) {
                    setState(() => _marketingPromotions = value);
                  },
          ),
        ],
      ),
    );
  }
}

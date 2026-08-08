import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../sub_accounts/presentation/sub_accounts_page.dart';
import '../../wallets/presentation/connect_paypal_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await FlowaServices.accountRepository.getCurrentUser();
    if (!mounted) {
      return;
    }
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return FlowaPage(
      title: 'Profile',
      child: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  user.email ?? FlowaConstants.appName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: FlowaSpacing.xl),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification settings'),
                  subtitle: const Text('Keep alerts useful, mute promotions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(
                      context,
                      const NotificationSettingsPage(),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_tree_outlined),
                  title: const Text('Sub-Accounts'),
                  subtitle: const Text('Family and business money control'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const SubAccountsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Connected wallets'),
                  subtitle: const Text('Link PayPal and external accounts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const ConnectPayPalPage());
                  },
                ),
                const Spacer(),
                FlowaPrimaryButton(
                  label: 'Open notification settings',
                  onPressed: () {
                    pushFlowaRoute<void>(
                      context,
                      const NotificationSettingsPage(),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

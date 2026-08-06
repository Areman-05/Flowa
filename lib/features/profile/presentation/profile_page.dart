import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../shared/widgets/flowa_buttons.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowaPage(
      title: 'Profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FlowaConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Settings, notifications, and support will live here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          FlowaPrimaryButton(
            label: 'Open notification settings',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

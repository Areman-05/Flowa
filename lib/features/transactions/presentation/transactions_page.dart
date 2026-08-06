import 'package:flutter/material.dart';

import '../../../shared/widgets/flowa_buttons.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FlowaPage(
      title: 'Transactions',
      child: Center(
        child: Text('Transaction history will appear here.'),
      ),
    );
  }
}

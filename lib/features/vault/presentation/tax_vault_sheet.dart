import 'package:flutter/material.dart';

import '../../../shared/navigation/flowa_routes.dart';
import 'tax_vault_page.dart';

/// Legacy entry — Bote is a full screen now.
Future<void> showTaxVaultSheet({
  required BuildContext context,
  Object? vault,
  Object? overview,
}) {
  return pushFlowaRoute<void>(context, const TaxVaultPage());
}

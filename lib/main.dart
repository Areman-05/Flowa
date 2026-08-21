import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/flowa_app.dart';
import 'core/utils/flowa_services.dart';
import 'data/datasources/local_auth_data_source.dart';
import 'data/datasources/local_preferences_data_source.dart';
import 'data/repositories/local_auth_repository.dart';
import 'data/repositories/local_preferences_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  final prefsSource = await LocalPreferencesDataSource.create();
  final authSource = await LocalAuthDataSource.create();
  FlowaServices.preferencesRepository = LocalPreferencesRepository(prefsSource);
  FlowaServices.authRepository = LocalAuthRepository(authSource);
  runApp(const FlowaApp());
}

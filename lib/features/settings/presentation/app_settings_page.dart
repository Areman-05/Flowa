import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/navigation/flowa_routes.dart';
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
    return FlowaScreen(
      title: 'Ajustes',
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ocultar saldo por defecto'),
                  subtitle: const Text('Inicio con el saldo enmascarado'),
                  value: _balanceHidden,
                  activeThumbColor: FlowaColors.mintInk,
                  activeTrackColor: FlowaColors.mint,
                  onChanged: (value) async {
                    setState(() => _balanceHidden = value);
                    await FlowaServices.preferencesRepository
                        .setBalanceHiddenByDefault(value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Modo oscuro'),
                  subtitle: const Text('Siempre activo en esta versión'),
                  value: _darkMode,
                  activeThumbColor: FlowaColors.mintInk,
                  activeTrackColor: FlowaColors.mint,
                  onChanged: (value) async {
                    setState(() => _darkMode = value);
                    await FlowaServices.preferencesRepository
                        .setDarkModeEnabled(value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Presupuesto mensual'),
                  subtitle: const Text('Controla el gasto en Análisis'),
                  value: _budgetEnabled,
                  activeThumbColor: FlowaColors.mintInk,
                  activeTrackColor: FlowaColors.mint,
                  onChanged: (value) async {
                    setState(() => _budgetEnabled = value);
                    await FlowaServices.preferencesRepository
                        .setBudgetEnabled(value);
                  },
                ),
                if (_budgetEnabled)
                  FlowaMenuRow(
                    glyph: FlowaGlyph.chart,
                    title: 'Límite de presupuesto',
                    subtitle: '€${_budgetLimit.toStringAsFixed(0)}',
                    onTap: () async {
                      final controller = TextEditingController(
                        text: _budgetLimit.toStringAsFixed(0),
                      );
                      final next = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: FlowaColors.inkHigh,
                            title: const Text('Presupuesto mensual'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: '€ ',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final value =
                                      double.tryParse(controller.text) ?? 0;
                                  Navigator.pop(context, value);
                                },
                                child: const Text('Guardar'),
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
                const SizedBox(height: FlowaSpacing.md),
                FlowaMenuRow(
                  glyph: FlowaGlyph.bell,
                  title: 'Notificaciones',
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const NotificationSettingsPage(),
                  ),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.lock,
                  title: 'Bloqueo de la app',
                  subtitle: 'PIN de 4 dígitos al abrir',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const PinSetupPage()),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.spark,
                  title: 'Acerca de Flowa',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const AboutPage()),
                ),
              ],
            ),
    );
  }
}

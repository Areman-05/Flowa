import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../lock/presentation/pin_lock_pages.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../sub_accounts/presentation/sub_accounts_page.dart';
import '../../wallets/presentation/wallets_page.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = FlowaServices.preferencesRepository;
    final hidden = await prefs.isBalanceHiddenByDefault();
    final budgetEnabled = await prefs.isBudgetEnabled();
    final budgetLimit = await prefs.getMonthlyBudgetLimit();
    if (!mounted) {
      return;
    }
    setState(() {
      _balanceHidden = hidden;
      _budgetEnabled = budgetEnabled;
      _budgetLimit = budgetLimit;
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
              padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
              children: [
                const _SettingsIntro(),
                const SizedBox(height: FlowaSpacing.lg),
                _SettingsSection(
                  title: 'Cuenta',
                  children: [
                    FlowaMenuRow(
                      glyph: FlowaGlyph.person,
                      title: 'Mi perfil',
                      subtitle: 'Datos personales y avatar',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const ProfilePage(),
                      ),
                    ),
                    FlowaMenuRow(
                      glyph: FlowaGlyph.vault,
                      title: 'Subcuentas',
                      subtitle: 'Familia, negocio y sobres',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const SubAccountsPage(),
                      ),
                    ),
                    FlowaMenuRow(
                      glyph: FlowaGlyph.card,
                      title: 'Carteras conectadas',
                      subtitle: 'PayPal y cuentas externas',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const WalletsPage(),
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  title: 'Privacidad y visualización',
                  children: [
                    _SettingsToggle(
                      title: 'Ocultar saldo por defecto',
                      subtitle: 'Inicio con el saldo enmascarado',
                      value: _balanceHidden,
                      onChanged: (value) async {
                        setState(() => _balanceHidden = value);
                        await FlowaServices.preferencesRepository
                            .setBalanceHiddenByDefault(value);
                      },
                    ),
                    _SettingsToggle(
                      title: 'Modo oscuro',
                      subtitle: 'Flowa usa solo canvas oscuro en esta demo',
                      value: true,
                      onChanged: null,
                    ),
                  ],
                ),
                _SettingsSection(
                  title: 'Seguridad',
                  children: [
                    FlowaMenuRow(
                      glyph: FlowaGlyph.lock,
                      title: 'Bloqueo con PIN',
                      subtitle: 'PIN de 4 dígitos al abrir la app',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const PinSetupPage(),
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  title: 'Finanzas',
                  children: [
                    _SettingsToggle(
                      title: 'Presupuesto mensual',
                      subtitle: 'Controla el gasto en Análisis',
                      value: _budgetEnabled,
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
                        onTap: _editBudget,
                      ),
                  ],
                ),
                _SettingsSection(
                  title: 'Notificaciones',
                  children: [
                    FlowaMenuRow(
                      glyph: FlowaGlyph.bell,
                      title: 'Alertas y avisos',
                      subtitle: 'Transacciones, marketing y más',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const NotificationSettingsPage(),
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  title: 'App',
                  children: [
                    FlowaMenuRow(
                      glyph: FlowaGlyph.spark,
                      title: 'Acerca de Flowa',
                      subtitle: 'Versión, licencias y créditos',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const AboutPage(),
                      ),
                    ),
                    FlowaMenuRow(
                      glyph: FlowaGlyph.receipt,
                      title: 'Exportar movimientos',
                      subtitle: 'Descarga CSV de tu actividad',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Exportación demo: movimientos_flowa.csv generado.',
                            ),
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                      },
                    ),
                    FlowaMenuRow(
                      glyph: FlowaGlyph.logout,
                      title: 'Cerrar sesión',
                      subtitle: 'Salir de la cuenta en este dispositivo',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cierra sesión desde Inicio → avatar → Perfil.',
                            ),
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _editBudget() async {
    final controller = TextEditingController(
      text: _budgetLimit.toStringAsFixed(0),
    );
    final next = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FlowaColors.inkHigh,
          title: Text('Presupuesto mensual', style: FlowaType.titleMd()),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: FlowaType.body(),
            decoration: const InputDecoration(prefixText: '€ '),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text) ?? 0;
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
      await FlowaServices.preferencesRepository.setMonthlyBudgetLimit(next);
    }
  }
}

class _SettingsIntro extends StatelessWidget {
  const _SettingsIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
        border: Border.all(color: FlowaColors.hairlineStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: FlowaColors.mintTintedSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const FlowaLucideIcon(
              LucideIcons.settings,
              size: 26,
              color: FlowaColors.mint,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu cuenta Flowa', style: FlowaType.titleMd()),
                const SizedBox(height: 4),
                Text(
                  'Privacidad, seguridad, notificaciones y preferencias.',
                  style: FlowaType.body(color: FlowaColors.boneMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: FlowaSpacing.sm),
            child: Text(title, style: FlowaType.titleMd()),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xlAll,
              border: Border.all(color: FlowaColors.hairlineStrong),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: FlowaType.titleSm()),
        subtitle: Text(
          subtitle,
          style: FlowaType.bodySm(color: FlowaColors.boneMuted),
        ),
        value: value,
        activeThumbColor: FlowaColors.mintInk,
        activeTrackColor: FlowaColors.mint,
        onChanged: onChanged,
      ),
    );
  }
}

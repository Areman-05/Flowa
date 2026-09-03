import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../domain/repositories/preferences_repository.dart';

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
    return FlowaScreen(
      title: 'Notificaciones',
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              children: [
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Permitir avisos'),
                    value: _allowNotifications,
                    activeThumbColor: FlowaColors.mintInk,
                    activeTrackColor: FlowaColors.mint,
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
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Movimientos'),
                    subtitle: const Text('Cuando entra o sale dinero'),
                    value: _allowNotifications && _transactionNotifications,
                    activeThumbColor: FlowaColors.mintInk,
                    activeTrackColor: FlowaColors.mint,
                    onChanged: !_allowNotifications
                        ? null
                        : (value) async {
                            setState(() => _transactionNotifications = value);
                            await _persist();
                          },
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Promos y marketing'),
                    subtitle: const Text('Novedades y ofertas. Mejor apagado.'),
                    value: _allowNotifications && _marketingPromotions,
                    activeThumbColor: FlowaColors.mintInk,
                    activeTrackColor: FlowaColors.mint,
                    onChanged: !_allowNotifications
                        ? null
                        : (value) async {
                            setState(() => _marketingPromotions = value);
                            await _persist();
                          },
                  ),
                ),
              ],
            ),
    );
  }
}

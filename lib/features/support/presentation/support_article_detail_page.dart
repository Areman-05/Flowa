import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/support_article.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../ai_assistant/presentation/ai_assistant_page.dart';
import '../../invoices/presentation/invoices_page.dart';
import '../../lock/presentation/pin_lock_pages.dart';
import '../../more/presentation/more_service_pages.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../send_money/presentation/send_money_page.dart';
import '../../sub_accounts/presentation/sub_accounts_page.dart';
import '../../wallets/presentation/wallets_page.dart';
import 'support_chat_page.dart';

class SupportArticleDetailPage extends StatelessWidget {
  const SupportArticleDetailPage({required this.article, super.key});

  final SupportArticle article;

  Future<void> _openAction(BuildContext context) async {
    final route = article.actionRoute;
    if (route == null) {
      return;
    }

    final page = switch (route) {
      'send' => const SendMoneyPage(),
      'subaccounts' => const SubAccountsPage(),
      'notifications' => const NotificationSettingsPage(),
      'wallets' => const WalletsPage(),
      'invoices' => const InvoicesPage(),
      'qr' => const MoreQrPayPage(),
      'pin' => const PinSetupPage(),
      _ => null,
    };

    if (page != null) {
      await pushFlowaRoute<void>(context, page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: article.category,
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          Text(article.title, style: FlowaType.titleLg()),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            article.summary,
            style: FlowaType.body(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Text('Pasos a seguir', style: FlowaType.titleMd()),
          const SizedBox(height: FlowaSpacing.md),
          for (var i = 0; i < article.steps.length; i++) ...[
            _StepRow(index: i + 1, text: article.steps[i]),
            if (i < article.steps.length - 1)
              const SizedBox(height: FlowaSpacing.sm),
          ],
          if (article.actionLabel != null) ...[
            const SizedBox(height: FlowaSpacing.xl),
            FlowaAcidButton(
              label: article.actionLabel!,
              onPressed: () => _openAction(context),
            ),
          ],
          const SizedBox(height: FlowaSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xlAll,
              border: Border.all(color: FlowaColors.hairlineStrong),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿No te ha servido?', style: FlowaType.titleSm()),
                const SizedBox(height: 6),
                Text(
                  'Escríbenos o pregunta al asistente.',
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
                const SizedBox(height: FlowaSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => pushFlowaRoute<void>(
                          context,
                          const SupportChatPage(),
                        ),
                        icon: const FlowaLucideIcon(
                          LucideIcons.message_circle,
                          size: 18,
                        ),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FlowaColors.bone,
                          side: const BorderSide(
                            color: FlowaColors.hairlineStrong,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => pushFlowaRoute<void>(
                          context,
                          const AiAssistantPage(),
                        ),
                        icon: const FlowaLucideIcon(
                          LucideIcons.sparkles,
                          size: 18,
                        ),
                        label: const Text('Asistente'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FlowaColors.bone,
                          side: const BorderSide(
                            color: FlowaColors.hairlineStrong,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.lgAll,
        border: Border.all(color: FlowaColors.hairlineStrong),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: FlowaColors.mintTintedSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: FlowaType.titleSm(color: FlowaColors.mint),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: FlowaType.body()),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_amount_chips.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/ai_chat_message.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../receive/presentation/receive_page.dart';
import '../../send_money/presentation/send_money_page.dart';
import '../../support/presentation/support_center_page.dart';
import '../../top_up/presentation/top_up_page.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late List<AiChatMessage> _messages;
  bool _chatStarted = false;

  @override
  void initState() {
    super.initState();
    _messages = FlowaServices.aiAssistant.messages;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startNewChat() async {
    FlowaServices.aiAssistant.reset();
    setState(() {
      _chatStarted = false;
      _messages = FlowaServices.aiAssistant.messages;
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) {
      return;
    }
    setState(() => _chatStarted = true);
    final messages = await FlowaServices.aiAssistant.sendUserMessage(text);
    if (!mounted) {
      return;
    }
    setState(() => _messages = messages);
    _controller.clear();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _quickAction(String label) async {
    if (label == 'Enviar') {
      await pushFlowaRoute<void>(context, const SendMoneyPage());
    } else if (label == 'Ingresar') {
      await pushFlowaRoute<void>(context, const ReceivePage());
    } else if (label == 'Recargar') {
      await pushFlowaRoute<void>(context, const TopUpPage());
    } else if (label == 'Soporte') {
      await pushFlowaRoute<void>(context, const SupportCenterPage());
    }
    await _send(label);
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Asistente',
      embedded: widget.embedded,
      actions: [
        FlowaIconAction(
          glyph: FlowaGlyph.spark,
          tooltip: 'Nuevo chat',
          onTap: _startNewChat,
        ),
      ],
      footer: TextField(
        controller: _controller,
        textInputAction: TextInputAction.send,
        onSubmitted: _send,
        style: FlowaType.body(color: FlowaColors.bone),
        decoration: InputDecoration(
          hintText: _chatStarted ? 'Pregunta lo que quieras' : 'Dime qué necesitas',
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FlowaPressScale(
              onTap: () => _send(_controller.text),
              scale: 0.92,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: FlowaColors.mint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const FlowaIcon(
                  FlowaGlyph.arrowUp,
                  size: 16,
                  color: FlowaColors.mintInk,
                ),
              ),
            ),
          ),
        ),
      ),
      child: !_chatStarted
          ? Column(
              children: [
                const Spacer(),
                const FlowaIconOrb(
                  glyph: FlowaGlyph.spark,
                  size: 72,
                  background: FlowaColors.mint,
                  foreground: FlowaColors.mintInk,
                ),
                const SizedBox(height: FlowaSpacing.lg),
                Text(
                  '¿En qué te ayudo?',
                  style: FlowaType.editorialMd(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FlowaSpacing.lg),
                Wrap(
                  spacing: FlowaSpacing.sm,
                  runSpacing: FlowaSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _AiChip(
                      label: 'Enviar',
                      glyph: FlowaGlyph.transfer,
                      onTap: () => _quickAction('Enviar'),
                    ),
                    _AiChip(
                      label: 'Ingresar',
                      glyph: FlowaGlyph.arrowDown,
                      onTap: () => _quickAction('Ingresar'),
                    ),
                    _AiChip(
                      label: 'Recargar',
                      glyph: FlowaGlyph.card,
                      onTap: () => _quickAction('Recargar'),
                    ),
                    _AiChip(
                      label: 'Soporte',
                      glyph: FlowaGlyph.spark,
                      onTap: () => _quickAction('Soporte'),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(
                  message: message,
                  onAmountSelected: (amount) {
                    _send('${amount.toStringAsFixed(0)} €');
                  },
                );
              },
            ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.onAmountSelected});

  final AiChatMessage message;
  final ValueChanged<double> onAmountSelected;

  @override
  Widget build(BuildContext context) {
    if (message.isTyping) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: FlowaSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: FlowaSpacing.md,
            vertical: FlowaSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: FlowaColors.inkHigh,
            borderRadius: FlowaRadii.lgAll,
          ),
          child: Text('Escribiendo…', style: FlowaType.bodySm()),
        ),
      );
    }

    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: FlowaSpacing.sm),
        padding: const EdgeInsets.all(FlowaSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? FlowaColors.mint : FlowaColors.inkHigh,
          borderRadius: FlowaRadii.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: FlowaType.body(
                color: isUser ? FlowaColors.mintInk : FlowaColors.bone,
              ),
            ),
            if (message.quickAmounts.isNotEmpty) ...[
              const SizedBox(height: FlowaSpacing.sm),
              FlowaAmountChips(
                values: message.quickAmounts,
                selected: null,
                onSelected: onAmountSelected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiChip extends StatelessWidget {
  const _AiChip({
    required this.label,
    required this.glyph,
    required this.onTap,
  });

  final String label;
  final FlowaGlyph glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FlowaSpacing.md,
          vertical: FlowaSpacing.sm,
        ),
        decoration: const BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowaIcon(glyph, size: 16, color: FlowaColors.mint),
            const SizedBox(width: FlowaSpacing.xs),
            Text(label, style: FlowaType.titleSm()),
          ],
        ),
      ),
    );
  }
}

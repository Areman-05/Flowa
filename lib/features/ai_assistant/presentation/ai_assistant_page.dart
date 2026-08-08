import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_amount_chips.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/ai_chat_message.dart';
import '../../receive/presentation/receive_page.dart';
import '../../send_money/presentation/send_money_page.dart';
import '../../top_up/presentation/top_up_page.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

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
    if (label == 'Send') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SendMoneyPage()),
      );
    } else if (label == 'Top-Up') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TopUpPage()),
      );
    } else if (label == 'Receive') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ReceivePage()),
      );
    }
    await _send(label);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: FlowaColors.background,
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: Column(
            children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _startNewChat,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Start a New Chat'),
              ),
            ),
            if (!_chatStarted) ...[
              const Spacer(),
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: FlowaColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(height: FlowaSpacing.md),
              Text(
                'What Can I Help You?',
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FlowaSpacing.lg),
              Wrap(
                spacing: FlowaSpacing.sm,
                runSpacing: FlowaSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  _AiChip(
                    label: 'Send',
                    icon: Icons.send_outlined,
                    onTap: () => _quickAction('Send'),
                  ),
                  _AiChip(
                    label: 'Receive',
                    icon: Icons.call_received,
                    onTap: () => _quickAction('Receive'),
                  ),
                  _AiChip(
                    label: 'Top-Up',
                    icon: Icons.phone_android,
                    onTap: () => _quickAction('Top-Up'),
                  ),
                  _AiChip(
                    label: 'Support',
                    icon: Icons.support_agent,
                    onTap: () => _quickAction('Support'),
                  ),
                  _AiChip(
                    label: 'More',
                    icon: Icons.more_horiz,
                    onTap: () => _quickAction('More'),
                  ),
                ],
              ),
              const Spacer(),
            ] else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _ChatBubble(
                      message: message,
                      onAmountSelected: (amount) {
                        _send('\$${amount.toStringAsFixed(0)}');
                      },
                    );
                  },
                ),
              ),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              decoration: InputDecoration(
                hintText: _chatStarted
                    ? 'Ask Anything'
                    : 'Tell me what do you want',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_none_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: FlowaSpacing.xs),
                      child: CircleAvatar(
                        backgroundColor: FlowaColors.primary,
                        child: IconButton(
                          onPressed: () => _send(_controller.text),
                          icon: const Icon(
                            Icons.send_rounded,
                            color: FlowaColors.textOnPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.onAmountSelected,
  });

  final AiChatMessage message;
  final ValueChanged<double> onAmountSelected;

  @override
  Widget build(BuildContext context) {
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
          color: isUser ? FlowaColors.primary : FlowaColors.surface,
          borderRadius: FlowaRadii.lgAll,
          border: isUser ? null : Border.all(color: FlowaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUser
                        ? FlowaColors.textOnPrimary
                        : FlowaColors.textPrimary,
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
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlowaColors.surface,
      borderRadius: FlowaRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: FlowaRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FlowaSpacing.md,
            vertical: FlowaSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: FlowaRadii.mdAll,
            border: Border.all(color: FlowaColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: FlowaColors.primary),
              const SizedBox(width: FlowaSpacing.xs),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

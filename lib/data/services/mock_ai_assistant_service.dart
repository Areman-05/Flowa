import '../../domain/entities/ai_chat_message.dart';

/// Lightweight mock assistant that guides users through money actions.
class MockAiAssistantService {
  MockAiAssistantService() {
    _messages = [
      AiChatMessage(
        id: 'ai-0',
        sender: AiMessageSender.assistant,
        text: "I'm Your AI Assistant. How Can I Assist You Today?",
        sentAt: DateTime.now(),
      ),
    ];
  }

  late List<AiChatMessage> _messages;
  int _counter = 0;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);

  void reset() {
    _counter = 0;
    _messages = [
      AiChatMessage(
        id: 'ai-0',
        sender: AiMessageSender.assistant,
        text: "I'm Your AI Assistant. How Can I Assist You Today?",
        sentAt: DateTime.now(),
      ),
    ];
  }

  Future<List<AiChatMessage>> sendUserMessage(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) {
      return messages;
    }

    _counter += 1;
    _messages = [
      ..._messages,
      AiChatMessage(
        id: 'user-$_counter',
        sender: AiMessageSender.user,
        text: text,
        sentAt: DateTime.now(),
      ),
    ];

    _counter += 1;
    _messages = [
      ..._messages,
      _replyFor(text, id: 'ai-$_counter'),
    ];
    return messages;
  }

  Future<List<AiChatMessage>> sendQuickAction(String action) {
    return sendUserMessage(action);
  }

  AiChatMessage _replyFor(String text, {required String id}) {
    final lower = text.toLowerCase();
    if (lower.contains('top-up') || lower.contains('top up')) {
      return AiChatMessage(
        id: id,
        sender: AiMessageSender.assistant,
        text:
            'I can help with a Top-Up. Choose an amount or type a custom value. '
            'Remember: Top-Up is for mobile recharge, not bank transfers.',
        sentAt: DateTime.now(),
        quickAmounts: const [5, 25, 50],
      );
    }
    if (lower.contains('send')) {
      return AiChatMessage(
        id: id,
        sender: AiMessageSender.assistant,
        text:
            'To send money, open Send and enter the recipient account details. '
            'I can also walk you through the steps here.',
        sentAt: DateTime.now(),
      );
    }
    if (lower.contains('support') || lower.contains('help')) {
      return AiChatMessage(
        id: id,
        sender: AiMessageSender.assistant,
        text:
            'Support is available from Profile and failed-transaction screens. '
            'Tell me what went wrong and I will guide you.',
        sentAt: DateTime.now(),
      );
    }
    return AiChatMessage(
      id: id,
      sender: AiMessageSender.assistant,
      text:
          'I can help with Send, Receive, Top-Up, Support, and More. '
          'What would you like to do?',
      sentAt: DateTime.now(),
    );
  }
}

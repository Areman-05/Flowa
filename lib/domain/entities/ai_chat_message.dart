import 'package:equatable/equatable.dart';

enum AiMessageSender {
  user,
  assistant,
}

class AiChatMessage extends Equatable {
  const AiChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentAt,
    this.quickAmounts = const [],
  });

  final String id;
  final AiMessageSender sender;
  final String text;
  final DateTime sentAt;
  final List<double> quickAmounts;

  bool get isUser => sender == AiMessageSender.user;

  @override
  List<Object?> get props => [id, sender, text, sentAt, quickAmounts];
}

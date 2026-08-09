import 'package:equatable/equatable.dart';

class SupportArticle extends Equatable {
  const SupportArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
  });

  final String id;
  final String title;
  final String summary;
  final String category;

  @override
  List<Object?> get props => [id, title, summary, category];
}

abstract final class SupportCatalog {
  static const articles = <SupportArticle>[
    SupportArticle(
      id: 's1',
      title: 'I meant to Send, not Top-Up',
      summary:
          'If a Top-Up confirmation appears, tap No, Go Back. Send Money uses a different purple flow.',
      category: 'Payments',
    ),
    SupportArticle(
      id: 's2',
      title: 'How do sub-accounts work?',
      summary:
          'Create Family or Business envelopes to keep personal and shop money separate.',
      category: 'Accounts',
    ),
    SupportArticle(
      id: 's3',
      title: 'Why did I miss a money request?',
      summary:
          'Turn off Marketing alerts and keep Transaction notifications on in Settings.',
      category: 'Notifications',
    ),
    SupportArticle(
      id: 's4',
      title: 'Connect PayPal securely',
      summary:
          'External wallet login is handled by PayPal. Flowa only stores connection status.',
      category: 'Wallets',
    ),
  ];
}

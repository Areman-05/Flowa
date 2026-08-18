import '../../domain/entities/finance_entities.dart';
import 'flowa_formatters.dart';

/// Builds shareable payment request copy for Receive.
abstract final class ReceiveRequest {
  static String build({
    required Account account,
    required double amount,
    String? note,
  }) {
    final buffer = StringBuffer(
      'Pay ${FlowaFormatters.currency(amount)} to ${account.displayName} '
      '(${account.maskedNumber}).',
    );
    final trimmed = note?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      buffer.write(' Note: $trimmed.');
    }
    return buffer.toString();
  }
}

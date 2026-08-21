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
      'Paga ${FlowaFormatters.currency(amount)} a ${account.displayName} '
      '(${account.maskedNumber}).',
    );
    final trimmed = note?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      buffer.write(' Nota: $trimmed.');
    }
    return buffer.toString();
  }
}

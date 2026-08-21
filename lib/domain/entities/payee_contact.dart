import 'package:equatable/equatable.dart';

enum PayeeKind {
  person,
  business,
}

/// Saved recipient (person or company) for Send Money.
class PayeeContact extends Equatable {
  const PayeeContact({
    required this.id,
    required this.name,
    required this.kind,
    this.accountNumber = '',
    this.note,
  });

  final String id;
  final String name;
  final PayeeKind kind;
  final String accountNumber;
  final String? note;

  String get kindLabel =>
      kind == PayeeKind.business ? 'Empresa' : 'Persona';

  @override
  List<Object?> get props => [id, name, kind, accountNumber, note];
}

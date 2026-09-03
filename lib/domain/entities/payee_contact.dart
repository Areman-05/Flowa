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

  PayeeContact copyWith({
    String? id,
    String? name,
    PayeeKind? kind,
    String? accountNumber,
    String? note,
    bool clearNote = false,
  }) {
    return PayeeContact(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      accountNumber: accountNumber ?? this.accountNumber,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  @override
  List<Object?> get props => [id, name, kind, accountNumber, note];
}

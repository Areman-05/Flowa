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
    this.useCount = 0,
    this.lastUsedAt,
  });

  final String id;
  final String name;
  final PayeeKind kind;
  final String accountNumber;
  final String? note;
  final int useCount;

  /// Last time this contact was chosen for a send (drives “Recientes”).
  final DateTime? lastUsedAt;

  String get kindLabel =>
      kind == PayeeKind.business ? 'Empresa' : 'Persona';

  PayeeContact copyWith({
    String? id,
    String? name,
    PayeeKind? kind,
    String? accountNumber,
    String? note,
    int? useCount,
    DateTime? lastUsedAt,
    bool clearNote = false,
    bool clearLastUsed = false,
  }) {
    return PayeeContact(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      accountNumber: accountNumber ?? this.accountNumber,
      note: clearNote ? null : (note ?? this.note),
      useCount: useCount ?? this.useCount,
      lastUsedAt: clearLastUsed ? null : (lastUsedAt ?? this.lastUsedAt),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, kind, accountNumber, note, useCount, lastUsedAt];
}

import '../../domain/entities/payee_contact.dart';
import '../../domain/repositories/contact_repository.dart';

class InMemoryContactRepository implements ContactRepository {
  InMemoryContactRepository({List<PayeeContact>? seed})
      : _items = List<PayeeContact>.from(seed ?? const []);

  static const List<PayeeContact> demoSeed = [
    PayeeContact(
      id: 'contact-demo-1',
      name: 'Emma Parker',
      kind: PayeeKind.person,
      accountNumber: 'ES9121000418450200051332',
      note: 'Alquiler',
    ),
    PayeeContact(
      id: 'contact-demo-2',
      name: 'Mega SL',
      kind: PayeeKind.business,
      accountNumber: 'ES7921000813610123456789',
      note: 'Facturas',
    ),
    PayeeContact(
      id: 'contact-demo-3',
      name: 'Carlos Ruiz',
      kind: PayeeKind.person,
      accountNumber: 'ES1000492352082414205416',
    ),
  ];

  final List<PayeeContact> _items;
  int _sequence = 100;

  @override
  Future<List<PayeeContact>> getAll() async {
    final items = List<PayeeContact>.from(_items)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  @override
  Future<PayeeContact> create({
    required String name,
    required PayeeKind kind,
    String accountNumber = '',
    String? note,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('El nombre es obligatorio');
    }
    _sequence += 1;
    final contact = PayeeContact(
      id: 'contact-$_sequence',
      name: trimmed,
      kind: kind,
      accountNumber: accountNumber.trim(),
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );
    _items.add(contact);
    return contact;
  }

  @override
  Future<PayeeContact> update(PayeeContact contact) async {
    final trimmed = contact.name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('El nombre es obligatorio');
    }
    final index = _items.indexWhere((item) => item.id == contact.id);
    if (index < 0) {
      throw ArgumentError('Contacto no encontrado');
    }
    final note = contact.note?.trim();
    final updated = PayeeContact(
      id: contact.id,
      name: trimmed,
      kind: contact.kind,
      accountNumber: contact.accountNumber.trim(),
      note: (note == null || note.isEmpty) ? null : note,
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}

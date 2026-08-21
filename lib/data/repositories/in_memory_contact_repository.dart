import '../../domain/entities/payee_contact.dart';
import '../../domain/repositories/contact_repository.dart';

class InMemoryContactRepository implements ContactRepository {
  InMemoryContactRepository({List<PayeeContact>? seed})
      : _items = List<PayeeContact>.from(seed ?? const []);

  final List<PayeeContact> _items;
  int _sequence = 0;

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
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}

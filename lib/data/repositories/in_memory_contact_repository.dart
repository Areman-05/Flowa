import '../../domain/entities/payee_contact.dart';
import '../../domain/repositories/contact_repository.dart';

class InMemoryContactRepository implements ContactRepository {
  InMemoryContactRepository({List<PayeeContact>? seed})
      : _items = List<PayeeContact>.from(seed ?? const []);

  /// Demo roster — Spanish freelance mix. [lastUsedAt] drives Send “Recientes”.
  static List<PayeeContact> get demoSeed {
    final now = DateTime.now();
    PayeeContact c(
      String id,
      String name,
      PayeeKind kind, {
      required String account,
      String? note,
      required int useCount,
      required int hoursAgo,
    }) {
      return PayeeContact(
        id: id,
        name: name,
        kind: kind,
        accountNumber: account,
        note: note,
        useCount: useCount,
        lastUsedAt: now.subtract(Duration(hours: hoursAgo)),
      );
    }

    return [
      c('contact-demo-1', 'Emma Parker', PayeeKind.person,
          account: 'ES91 2100 0418 4502 0005 1332',
          note: 'Alquiler',
          useCount: 42,
          hoursAgo: 2),
      c('contact-demo-2', 'Gestoría Ordoñez', PayeeKind.business,
          account: 'ES79 2100 0813 6101 2345 6789',
          note: 'Asesoría',
          useCount: 38,
          hoursAgo: 5),
      c('contact-demo-3', 'Carlos Ruiz', PayeeKind.person,
          account: 'ES10 0049 2352 0824 1420 5416',
          note: 'Café / splits',
          useCount: 31,
          hoursAgo: 8),
      c('contact-demo-4', 'Lucía Méndez', PayeeKind.person,
          account: 'ES21 0081 0312 4100 1234 5678',
          note: 'Coworking',
          useCount: 27,
          hoursAgo: 12),
      c('contact-demo-5', 'Agencia Norte', PayeeKind.business,
          account: 'ES66 0075 0243 0606 0000 1234',
          note: 'Cliente',
          useCount: 22,
          hoursAgo: 20),
      c('contact-demo-6', 'Marta Soler', PayeeKind.person,
          account: 'ES94 2100 0418 4502 0008 8877',
          useCount: 18,
          hoursAgo: 36),
      c('contact-demo-7', 'Adobe', PayeeKind.business,
          account: 'ES12 0128 0012 3901 0004 5678',
          note: 'Suscripción',
          useCount: 14,
          hoursAgo: 48),
      c('contact-demo-8', 'Hugo Pardo', PayeeKind.person,
          account: 'ES55 0182 0345 6700 9876 5432',
          useCount: 11,
          hoursAgo: 72),
      c('contact-demo-9', 'Clara Paz', PayeeKind.person,
          account: 'ES30 0049 1820 4120 0001 9988',
          note: 'Proyecto web',
          useCount: 9,
          hoursAgo: 96),
      c('contact-demo-10', 'La Nave Cowork', PayeeKind.business,
          account: 'ES88 2100 1234 5600 0000 3344',
          note: 'Escritorio',
          useCount: 8,
          hoursAgo: 120),
      c('contact-demo-11', 'Iker Navarro', PayeeKind.person,
          account: 'ES47 0182 6035 4100 7654 3210',
          useCount: 6,
          hoursAgo: 150),
      c('contact-demo-12', 'Sofía Ríos', PayeeKind.person,
          account: 'ES73 0081 5300 7000 1122 3344',
          useCount: 5,
          hoursAgo: 180),
      c('contact-demo-13', 'Estudio Vértice', PayeeKind.business,
          account: 'ES19 2100 9876 5400 0011 2233',
          note: 'Colaboración',
          useCount: 4,
          hoursAgo: 220),
      c('contact-demo-14', 'Pablo Arenas', PayeeKind.person,
          account: 'ES61 0049 1500 0512 3456 7892',
          note: 'Cuenta propia',
          useCount: 3,
          hoursAgo: 260),
      c('contact-demo-15', 'Nuria Vidal', PayeeKind.person,
          account: 'ES02 0075 1001 0600 0000 5566',
          useCount: 2,
          hoursAgo: 300),
      c('contact-demo-16', 'Taxfix Barcelona', PayeeKind.business,
          account: 'ES36 2100 5555 0000 7777 8888',
          note: 'IVA / gestoría',
          useCount: 2,
          hoursAgo: 340),
      c('contact-demo-17', 'Diego Ferrer', PayeeKind.person,
          account: 'ES14 0182 2200 1100 3344 5566',
          useCount: 1,
          hoursAgo: 400),
      c('contact-demo-18', 'Marina Costa', PayeeKind.person,
          account: 'ES50 0081 0400 2200 9988 7766',
          useCount: 1,
          hoursAgo: 500),
    ];
  }

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
      useCount: contact.useCount,
      lastUsedAt: contact.lastUsedAt,
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<PayeeContact> touch(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw ArgumentError('Contacto no encontrado');
    }
    final current = _items[index];
    final updated = current.copyWith(
      useCount: current.useCount + 1,
      lastUsedAt: DateTime.now(),
    );
    _items[index] = updated;
    return updated;
  }
}

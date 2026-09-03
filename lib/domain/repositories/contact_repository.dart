import '../entities/payee_contact.dart';

abstract class ContactRepository {
  Future<List<PayeeContact>> getAll();

  Future<PayeeContact> create({
    required String name,
    required PayeeKind kind,
    String accountNumber,
    String? note,
  });

  Future<PayeeContact> update(PayeeContact contact);

  Future<void> delete(String id);
}

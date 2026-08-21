import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/sub_account_repository.dart';

class MockSubAccountRepository implements SubAccountRepository {
  MockSubAccountRepository({List<SubAccount>? seed})
      : _items = List<SubAccount>.from(seed ?? const []);

  final List<SubAccount> _items;
  int _sequence = 100;

  @override
  Future<List<SubAccount>> getAll() async {
    return List<SubAccount>.unmodifiable(_items);
  }

  @override
  Future<SubAccount> create({
    required String name,
    required AccountKind purpose,
    required AccessLevel accessLevel,
    required String iconKey,
    String? linkedEmail,
  }) async {
    _sequence += 1;
    final email = linkedEmail?.trim();
    final created = SubAccount(
      id: 'sub-$_sequence',
      name: name.trim(),
      accountNumber: _generateAccountNumber(_sequence),
      purpose: purpose,
      accessLevel: accessLevel,
      iconKey: iconKey,
      linkedEmail: (email == null || email.isEmpty) ? null : email,
    );
    _items.insert(0, created);
    return created;
  }

  static String _generateAccountNumber(int sequence) {
    final raw = '147658495748${sequence.toString().padLeft(4, '0')}';
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

import 'package:flutter_test/flutter_test.dart';

import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_contact_repository.dart';
import 'package:flowa/domain/entities/payee_contact.dart';
import 'package:flowa/domain/repositories/auth_repository.dart';

void main() {
  group('InMemoryAuthRepository', () {
    test('register then login succeeds', () async {
      final auth = InMemoryAuthRepository();
      final user = await auth.register(
        fullName: 'Ana López',
        email: 'ana@mail.com',
        password: '1234',
      );
      expect(user.email, 'ana@mail.com');
      expect(await auth.isLoggedIn(), isTrue);

      await auth.logout();
      expect(await auth.isLoggedIn(), isFalse);

      final again = await auth.login(email: 'ana@mail.com', password: '1234');
      expect(again.fullName, 'Ana López');
    });

    test('rejects wrong password', () async {
      final auth = InMemoryAuthRepository();
      await auth.register(
        fullName: 'Ana',
        email: 'ana@mail.com',
        password: '1234',
      );
      await auth.logout();
      expect(
        () => auth.login(email: 'ana@mail.com', password: 'bad'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('InMemoryContactRepository', () {
    test('creates and lists contacts', () async {
      final repo = InMemoryContactRepository();
      expect(await repo.getAll(), isEmpty);
      await repo.create(
        name: 'Mega SL',
        kind: PayeeKind.business,
        accountNumber: '1234',
      );
      final items = await repo.getAll();
      expect(items, hasLength(1));
      expect(items.first.kindLabel, 'Empresa');
    });
  });
}

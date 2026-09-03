import 'package:flutter_test/flutter_test.dart';

import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_contact_repository.dart';
import 'package:flowa/domain/entities/payee_contact.dart';
import 'package:flowa/domain/repositories/auth_repository.dart';

void main() {
  group('InMemoryAuthRepository', () {
    test('register then unlock succeeds', () async {
      final auth = InMemoryAuthRepository();
      final user = await auth.register(
        fullName: 'Ana López',
        email: 'ana@mail.com',
        password: 'Flowa1234',
      );
      expect(user.email, 'ana@mail.com');
      expect(await auth.isLoggedIn(), isTrue);

      await auth.logout();
      expect(await auth.isLoggedIn(), isFalse);

      final again = await auth.unlockWithPassword('Flowa1234');
      expect(again.fullName, 'Ana López');
    });

    test('rejects weak password on register', () async {
      final auth = InMemoryAuthRepository();
      expect(
        () => auth.register(
          fullName: 'Ana',
          email: 'ana@mail.com',
          password: '1234',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('rejects wrong password on unlock', () async {
      final auth = InMemoryAuthRepository();
      await auth.register(
        fullName: 'Ana',
        email: 'ana@mail.com',
        password: 'Flowa1234',
      );
      await auth.logout();
      expect(
        () => auth.unlockWithPassword('badpass1'),
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

      final updated = await repo.update(
        items.first.copyWith(name: 'Mega Corp', note: 'VIP'),
      );
      expect(updated.name, 'Mega Corp');
      expect(updated.note, 'VIP');
    });
  });
}

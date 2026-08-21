import '../../domain/entities/finance_entities.dart';

extension AccountKindLabels on AccountKind {
  String get label {
    return switch (this) {
      AccountKind.personal => 'Personal',
      AccountKind.family => 'Familiar',
      AccountKind.business => 'Empresa',
    };
  }
}

extension AccessLevelLabels on AccessLevel {
  String get label {
    return switch (this) {
      AccessLevel.limited => 'Limitado',
      AccessLevel.full => 'Completo',
    };
  }
}

import '../../domain/entities/finance_entities.dart';

extension AccountKindLabels on AccountKind {
  String get label {
    return switch (this) {
      AccountKind.personal => 'Personal',
      AccountKind.family => 'Family',
      AccountKind.business => 'Business',
    };
  }
}

extension AccessLevelLabels on AccessLevel {
  String get label {
    return switch (this) {
      AccessLevel.limited => 'Limited',
      AccessLevel.full => 'Full',
    };
  }
}

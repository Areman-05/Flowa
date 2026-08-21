import 'package:equatable/equatable.dart';

/// Locally authenticated Flowa user (no remote backend).
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
  });

  final String id;
  final String fullName;
  final String email;

  @override
  List<Object?> get props => [id, fullName, email];
}

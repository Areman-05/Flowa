import 'package:equatable/equatable.dart';

enum WalletProvider {
  paypal,
  bank,
}

enum WalletConnectionStatus {
  disconnected,
  connected,
}

class LinkedWallet extends Equatable {
  const LinkedWallet({
    required this.id,
    required this.provider,
    required this.status,
    this.email,
    this.displayName,
  });

  final String id;
  final WalletProvider provider;
  final WalletConnectionStatus status;
  final String? email;
  final String? displayName;

  bool get isConnected => status == WalletConnectionStatus.connected;

  LinkedWallet copyWith({
    WalletConnectionStatus? status,
    String? email,
    String? displayName,
  }) {
    return LinkedWallet(
      id: id,
      provider: provider,
      status: status ?? this.status,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props => [id, provider, status, email, displayName];
}

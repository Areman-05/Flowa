/// Distinguishes money actions so UI/copy never conflate them.
enum MoneyFlowKind {
  send,
  topUp,
  receive,
}

extension MoneyFlowKindX on MoneyFlowKind {
  String get title {
    switch (this) {
      case MoneyFlowKind.send:
        return 'Send Money';
      case MoneyFlowKind.topUp:
        return 'Top-Up';
      case MoneyFlowKind.receive:
        return 'Receive';
    }
  }

  String get clarification {
    switch (this) {
      case MoneyFlowKind.send:
        return 'Bank transfer to another account.';
      case MoneyFlowKind.topUp:
        return 'Mobile/operator recharge only.';
      case MoneyFlowKind.receive:
        return 'Request or share your account to get paid.';
    }
  }

  bool get requiresDestructiveConfirmation => this == MoneyFlowKind.topUp;
}

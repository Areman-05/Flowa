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
        return 'Enviar dinero';
      case MoneyFlowKind.topUp:
        return 'Recargar';
      case MoneyFlowKind.receive:
        return 'Recibir';
    }
  }

  String get clarification {
    switch (this) {
      case MoneyFlowKind.send:
        return 'Transferencia bancaria a otra cuenta.';
      case MoneyFlowKind.topUp:
        return 'Solo recarga de móvil/operador.';
      case MoneyFlowKind.receive:
        return 'Solicita o comparte tu cuenta para cobrar.';
    }
  }

  bool get requiresDestructiveConfirmation => this == MoneyFlowKind.topUp;
}

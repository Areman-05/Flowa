import 'package:equatable/equatable.dart';

class SupportArticle extends Equatable {
  const SupportArticle({
    required this.id,
    required this.title,
    required this.teaser,
    required this.summary,
    required this.category,
    required this.steps,
    this.actionLabel,
    this.actionRoute,
  });

  final String id;
  final String title;
  final String teaser;
  final String summary;
  final String category;
  final List<String> steps;
  final String? actionLabel;
  final String? actionRoute;

  @override
  List<Object?> get props =>
      [id, title, teaser, summary, category, steps, actionLabel, actionRoute];
}

abstract final class SupportCatalog {
  static const articles = <SupportArticle>[
    SupportArticle(
      id: 's1',
      title: 'Quería enviar dinero, no recargar',
      teaser: 'Evita confirmar una recarga por error',
      summary:
          'Enviar dinero y recargar saldo son flujos distintos. Si confirmas una recarga sin querer, el importe se añade a tu saldo pero no llega al destinatario.',
      category: 'Pagos',
      steps: [
        'Si aparece la pantalla de recarga, pulsa «No, volver».',
        'Para enviar dinero, usa el botón «Enviar» en Inicio (flujo morado).',
        'Revisa nombre del destinatario e importe antes de confirmar.',
        'En Movimientos verás «Recarga» o «Transferencia» según lo que hayas hecho.',
      ],
      actionLabel: 'Ir a Enviar dinero',
      actionRoute: 'send',
    ),
    SupportArticle(
      id: 's2',
      title: '¿Cómo funcionan las subcuentas?',
      teaser: 'Separa dinero personal y de negocio',
      summary:
          'Las subcuentas son sobres dentro de tu cuenta principal. Te ayudan a organizar ahorro, gastos familiares o facturación freelance.',
      category: 'Cuentas',
      steps: [
        'Ve a Perfil → Subcuentas.',
        'Pulsa «Crear subcuenta» y elige nombre e icono.',
        'Transfiere dinero desde tu saldo principal al sobre.',
        'Los movimientos del sobre no mezclan con tu cuenta personal.',
      ],
      actionLabel: 'Ver subcuentas',
      actionRoute: 'subaccounts',
    ),
    SupportArticle(
      id: 's3',
      title: '¿Por qué no vi una solicitud de dinero?',
      teaser: 'Revisa tus notificaciones',
      summary:
          'Las solicitudes de dinero generan una alerta push. Si no la recibiste, puede deberse a la configuración de avisos o al modo no molestar del móvil.',
      category: 'Notificaciones',
      steps: [
        'Abre Más → Ajustes → Notificaciones.',
        'Activa «Transacciones» y desactiva «Marketing» si prefieres menos ruido.',
        'Comprueba que Flowa tenga permiso de notificaciones en el sistema.',
        'Las solicitudes pendientes también aparecen en la campana de Inicio.',
      ],
      actionLabel: 'Configurar notificaciones',
      actionRoute: 'notifications',
    ),
    SupportArticle(
      id: 's4',
      title: 'Conectar PayPal de forma segura',
      teaser: 'Tu contraseña no pasa por Flowa',
      summary:
          'La conexión con PayPal se hace en su web oficial. Flowa solo guarda si la cuenta está vinculada, nunca tus credenciales.',
      category: 'Carteras',
      steps: [
        'Ve a Perfil → Carteras conectadas.',
        'Pulsa «Conectar PayPal».',
        'Inicia sesión en la página de PayPal (no en Flowa).',
        'Autoriza la conexión y vuelve a la app.',
      ],
      actionLabel: 'Ver carteras',
      actionRoute: 'wallets',
    ),
    SupportArticle(
      id: 's5',
      title: 'Cobrar a clientes',
      teaser: 'Sigue y cobra desde Por cobrar',
      summary:
          'Por cobrar es lo que te deben tus clientes. Al cobrar puedes ingresar en Flowa (y alimentar el bote) o marcar que ya cobraste fuera.',
      category: 'Cobros',
      steps: [
        'Abre la pestaña Por cobrar.',
        'Revisa los cobros pendientes.',
        'Pulsa Cobrar y elige cómo cerrarlo.',
        'En Historial verás el detalle de cada cobro.',
      ],
      actionLabel: 'Ir a Por cobrar',
      actionRoute: 'invoices',
    ),
    SupportArticle(
      id: 's6',
      title: 'Configurar el bote fiscal',
      teaser: 'Reserva automática para impuestos',
      summary:
          'El bote fiscal aparta un porcentaje de tus ingresos para que no te pille desprevenido a la hora de pagar impuestos o cuotas de autónomo.',
      category: 'Autónomos',
      steps: [
        'En Inicio, entra en la tarjeta «Bote fiscal».',
        'Define el porcentaje a reservar (p. ej. 20 %).',
        'Cada ingreso moverá esa parte al bote automáticamente.',
        'Puedes retirar del bote cuando necesites pagar impuestos.',
      ],
    ),
    SupportArticle(
      id: 's7',
      title: 'Pagar con código QR',
      teaser: 'Escanea y paga en comercio',
      summary:
          'El pago QR permite pagar en tiendas físicas escaneando un código. Necesitas permitir el acceso a la cámara del móvil.',
      category: 'Pagos',
      steps: [
        'Ve a Más → Pago QR.',
        'Pulsa «Toca para escanear» y acepta el permiso de cámara.',
        'Apunta al código del comercio hasta que se detecte.',
        'Introduce o confirma el importe y pulsa «Confirmar pago».',
      ],
      actionLabel: 'Abrir Pago QR',
      actionRoute: 'qr',
    ),
    SupportArticle(
      id: 's8',
      title: 'Cambiar o recuperar el PIN',
      teaser: 'Protege el acceso a tu cuenta',
      summary:
          'El PIN de 4 dígitos bloquea la app al abrirla. Puedes cambiarlo cuando quieras o contactar soporte si lo olvidaste.',
      category: 'Seguridad',
      steps: [
        'Ve a Más → Ajustes → Bloqueo con PIN.',
        'Introduce tu PIN actual y el nuevo dos veces.',
        'Activa también el desbloqueo biométrico si tu móvil lo permite.',
        'Si olvidaste el PIN, escríbenos por chat con tu email registrado.',
      ],
      actionLabel: 'Configurar PIN',
      actionRoute: 'pin',
    ),
  ];
}

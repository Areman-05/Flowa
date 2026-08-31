import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isAgent,
    required this.time,
  });

  final String text;
  final bool isAgent;
  final String time;
}

/// Chat de soporte en vivo (demo).
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final _messages = <_ChatMessage>[
    const _ChatMessage(
      text: '¡Hola! Soy Laura del equipo Flowa. ¿En qué puedo ayudarte?',
      isAgent: true,
      time: 'Ahora',
    ),
  ];

  static const _quickReplies = [
    'Problema con un pago',
    'Cambiar PIN',
    'Factura no aparece',
    'Hablar con un humano',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isAgent: false, time: 'Ahora'));
      _controller.clear();
    });
    await _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }

    final reply = _agentReply(text);
    setState(() {
      _messages.add(_ChatMessage(text: reply, isAgent: true, time: 'Ahora'));
    });
    await _scrollToBottom();
  }

  String _agentReply(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('pago') || lower.contains('transfer')) {
      return 'Revisa Movimientos y confirma que el estado sea "Completado". '
          'Si sigue pendiente, indícame la fecha y el importe.';
    }
    if (lower.contains('pin') || lower.contains('bloqueo')) {
      return 'Ve a Más → Ajustes → Bloqueo de la app para cambiar tu PIN. '
          'Si lo olvidaste, te envío un enlace de recuperación por email.';
    }
    if (lower.contains('factura')) {
      return 'Las facturas emitidas están en la pestaña Facturas. '
          '¿Buscas una emitida o una recibida de un cliente?';
    }
    if (lower.contains('humano') || lower.contains('persona')) {
      return 'Te paso con un agente senior. Tiempo de espera estimado: 2 min. '
          'Mientras tanto, ¿puedes describir tu consulta?';
    }
    return 'Entendido. Estoy revisando tu cuenta demo. '
        '¿Puedes darme más detalle para ayudarte mejor?';
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Chat en vivo',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: FlowaColors.mintTintedSurface,
              borderRadius: FlowaRadii.lgAll,
              border: Border.all(color: FlowaColors.mint.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: FlowaColors.mint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Laura · Soporte Flowa · Respuesta ~1 min',
                    style: FlowaType.bodySm(color: FlowaColors.mint),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _quickReplies[index];
                return FlowaPressScale(
                  onTap: () => _send(label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: FlowaColors.inkHigh,
                      borderRadius: FlowaRadii.pillAll,
                      border: Border.all(color: FlowaColors.hairlineStrong),
                    ),
                    child: Text(label, style: FlowaType.bodySm()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _Bubble(message: msg);
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: FlowaType.body(),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje…',
                    hintStyle: FlowaType.body(color: FlowaColors.boneMuted),
                    filled: true,
                    fillColor: FlowaColors.inkHigh,
                    border: OutlineInputBorder(
                      borderRadius: FlowaRadii.pillAll,
                      borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: FlowaRadii.pillAll,
                      borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 10),
              FlowaPressScale(
                onTap: () => _send(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: FlowaColors.mint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const FlowaLucideIcon(
                    LucideIcons.send,
                    size: 20,
                    color: FlowaColors.mintInk,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final align = message.isAgent ? Alignment.centerLeft : Alignment.centerRight;
    final bg = message.isAgent ? FlowaColors.inkHigh : FlowaColors.mintTintedSurface;
    final border = message.isAgent
        ? FlowaColors.hairlineStrong
        : FlowaColors.mint.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: FlowaRadii.lgAll,
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.text, style: FlowaType.body()),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

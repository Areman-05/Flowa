import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

/// Escáner QR con cámara y permisos.
class MoreQrScannerPage extends StatefulWidget {
  const MoreQrScannerPage({super.key});

  @override
  State<MoreQrScannerPage> createState() => _MoreQrScannerPageState();
}

class _MoreQrScannerPageState extends State<MoreQrScannerPage> {
  MobileScannerController? _controller;
  bool _permissionGranted = false;
  bool _checking = true;
  bool _scanned = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) {
      return;
    }

    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
        _checking = false;
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _checking = false;
        _error =
            'Permiso de cámara denegado. Actívalo en Ajustes del dispositivo.';
      });
    } else {
      setState(() {
        _checking = false;
        _error = 'Necesitamos acceso a la cámara para escanear códigos QR.';
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) {
      return;
    }
    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue?.trim();
    if (value == null || value.isEmpty) {
      return;
    }
    _scanned = true;
    Navigator.pop(context, value);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowaColors.ink,
      appBar: AppBar(
        backgroundColor: FlowaColors.ink,
        foregroundColor: FlowaColors.bone,
        title: Text('Escanear QR', style: FlowaType.titleMd()),
        leading: IconButton(
          icon: const FlowaLucideIcon(LucideIcons.x, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_checking) {
      return const Center(
        child: CircularProgressIndicator(color: FlowaColors.mint),
      );
    }

    if (_error != null) {
      return Padding(
        padding: FlowaSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: FlowaColors.inkHigh,
                shape: BoxShape.circle,
                border: Border.all(color: FlowaColors.hairlineStrong),
              ),
              alignment: Alignment.center,
              child: const FlowaLucideIcon(
                LucideIcons.camera_off,
                size: 32,
                color: FlowaColors.boneMuted,
              ),
            ),
            const SizedBox(height: FlowaSpacing.lg),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: FlowaType.body(color: FlowaColors.boneMuted),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            if (_error!.contains('Ajustes'))
              FilledButton(
                onPressed: () => openAppSettings(),
                style: FilledButton.styleFrom(
                  backgroundColor: FlowaColors.mint,
                  foregroundColor: FlowaColors.mintInk,
                ),
                child: const Text('Abrir ajustes'),
              )
            else
              FilledButton(
                onPressed: () {
                  setState(() {
                    _checking = true;
                    _error = null;
                  });
                  _initCamera();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: FlowaColors.mint,
                  foregroundColor: FlowaColors.mintInk,
                ),
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    if (!_permissionGranted || _controller == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(
                color: FlowaColors.mint.withValues(alpha: 0.85),
                width: 3,
              ),
              borderRadius: FlowaRadii.xlAll,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: FlowaSpacing.xl + 16,
          child: Column(
            children: [
              Text(
                'Apunta al código QR del comercio',
                style: FlowaType.titleSm(color: FlowaColors.bone),
              ),
              const SizedBox(height: 8),
              Text(
                'El pago se completará al volver',
                style: FlowaType.bodySm(color: FlowaColors.boneMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

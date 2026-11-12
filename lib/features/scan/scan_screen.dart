import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/car_link.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// Scans a car's QR code and opens that car's details.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handle(String raw) async {
    if (_busy) return;
    final carId = CarLink.parse(raw);
    if (carId == null) {
      showMessage(context, 'That is not an OFC car code.');
      return;
    }
    setState(() => _busy = true);
    try {
      final car = await ref.read(repositoriesProvider).cars.getCar(carId);
      if (!mounted) return;
      if (car == null) {
        showMessage(context, 'That car is no longer listed.');
      } else {
        context.pushReplacement('/car/${car.id}');
        return;
      }
    } catch (_) {
      if (mounted) {
        showMessage(context, 'Could not look up that car. Try again.');
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _enterManually() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter the car code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Code printed under the QR',
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Find car'),
          ),
        ],
      ),
    );
    if (code != null && code.trim().isNotEmpty && mounted) {
      await _handle(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan a car', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Toggle flash',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final value = capture.barcodes.firstOrNull?.rawValue;
              if (value != null) _handle(value);
            },
            errorBuilder: (context, error) => _CameraProblem(
              permissionDenied:
                  error.errorCode == MobileScannerErrorCode.permissionDenied,
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          if (_busy) const Center(child: CircularProgressIndicator()),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: SafeArea(
              child: Column(
                children: [
                  const Text(
                    'Point the camera at the QR code on the car',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: _enterManually,
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('Enter code instead'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraProblem extends StatelessWidget {
  const _CameraProblem({required this.permissionDenied});

  final bool permissionDenied;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            permissionDenied
                ? 'Camera access is off. Allow it in your phone settings, or enter the code by hand.'
                : 'The camera is not available. You can enter the code by hand.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

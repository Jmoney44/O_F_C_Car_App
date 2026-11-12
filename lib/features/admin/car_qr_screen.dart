import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/car_link.dart';
import '../../core/config.dart';
import '../../core/formatters.dart';
import '../../models/car.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

/// A6 label with the QR code, ready to print and place on the car.
Future<Uint8List> buildCarLabelPdf(Car car) async {
  final document = pw.Document(title: 'QR label - ${car.title}');
  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a6,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            AppConfig.appName.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(
              errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
            ),
            data: CarLink.forCar(car.id),
            width: 190,
            height: 190,
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            car.title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${car.color} - ${formatKm(car.mileageKm)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Scan with the ${AppConfig.appName} app for full details',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Code: ${car.id}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    ),
  );
  return document.save();
}

class CarQrScreen extends ConsumerWidget {
  const CarQrScreen({super.key, required this.carId});

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('QR code')),
      body: AsyncView<Car?>(
        value: ref.watch(carProvider(carId)),
        data: (car) {
          if (car == null) {
            return const EmptyState(
              icon: Icons.no_crash_outlined,
              title: 'This car no longer exists',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                // Always black on white so any scanner can read it, in
                // light and dark mode alike.
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: QrImageView(
                    data: CarLink.forCar(car.id),
                    size: 240,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                car.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'Code: ${car.id}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => runGuarded(
                  context,
                  () => Printing.layoutPdf(
                    name: 'QR label - ${car.title}',
                    format: PdfPageFormat.a6,
                    onLayout: (_) => buildCarLabelPdf(car),
                  ),
                ),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print label'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => runGuarded(
                  context,
                  () async => Printing.sharePdf(
                    bytes: await buildCarLabelPdf(car),
                    filename: 'ofc-qr-${car.id}.pdf',
                  ),
                ),
                icon: const Icon(Icons.ios_share),
                label: const Text('Share as PDF'),
              ),
              const SizedBox(height: 20),
              Text(
                'Put the printed label on the car. Customers who scan it in '
                'the app land on this car\'s page. The code stays the same '
                'when you edit the car.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

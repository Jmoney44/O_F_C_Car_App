import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// Reusable e-receipt, used for both order checkouts and wallet top-ups.
/// The barcode is a decorative pattern of bars, not a real scannable
/// barcode; Share/Download/Print are decorative taps (no share_plus/pdf
/// dependency added for a demo receipt).
class EReceiptScreen extends StatelessWidget {
  final String? imageUrl;
  final String itemTitle;
  final String? itemSubtitle;
  final num itemAmount;
  final num? shippingAmount;
  final num? taxAmount;
  final num totalAmount;
  final String paymentMethodLabel;
  final String date;
  final String transactionId;

  const EReceiptScreen({
    super.key,
    this.imageUrl,
    required this.itemTitle,
    this.itemSubtitle,
    required this.itemAmount,
    this.shippingAmount,
    this.taxAmount,
    required this.totalAmount,
    required this.paymentMethodLabel,
    required this.date,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: eReceipt.text.fontFamily(bold).color(darkFontGrey).make(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: darkFontGrey),
            onSelected: (value) => VxToast.show(context, msg: "$value not available in this demo"),
            itemBuilder: (context) => [
              PopupMenuItem(value: shareEReceipt, child: shareEReceipt.text.make()),
              PopupMenuItem(value: downloadEReceipt, child: downloadEReceipt.text.make()),
              PopupMenuItem(value: printReceipt, child: printReceipt.text.make()),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Barcode(seed: transactionId.hashCode),
            8.heightBox,
            transactionId.text.center.color(fontGrey).size(12).make(),
            20.heightBox,
            if (imageUrl != null || itemSubtitle != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    if (imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(imageUrl!, width: 56, height: 56, fit: BoxFit.cover),
                      ),
                      12.widthBox,
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          itemTitle.text.fontFamily(semibold).color(darkFontGrey).make(),
                          if (itemSubtitle != null) ...[
                            4.heightBox,
                            itemSubtitle!.text.color(fontGrey).size(13).make(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            20.heightBox,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row(amount, "$itemAmount".numCurrency),
                  if (shippingAmount != null) ...[
                    8.heightBox,
                    _row(shipping, "$shippingAmount".numCurrency),
                  ],
                  if (taxAmount != null) ...[
                    8.heightBox,
                    _row(tax, "$taxAmount".numCurrency),
                  ],
                  const Divider(height: 24, color: textfieldGrey),
                  _row(total, "$totalAmount".numCurrency, emphasize: true),
                ],
              ),
            ),
            16.heightBox,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row("Payment Methods", paymentMethodLabel),
                  8.heightBox,
                  _row("Date", date),
                  8.heightBox,
                  _row("Transaction ID", transactionId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.text.color(fontGrey).make(),
        value.text.color(darkFontGrey).fontFamily(emphasize ? bold : semibold).make(),
      ],
    );
  }
}

class _Barcode extends StatelessWidget {
  final int seed;
  const _Barcode({required this.seed});

  @override
  Widget build(BuildContext context) {
    final rand = Random(seed);
    return SizedBox(
      height: 70,
      child: Row(
        children: List.generate(48, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              color: rand.nextBool() ? darkFontGrey : Colors.transparent,
            ),
          );
        }),
      ),
    );
  }
}

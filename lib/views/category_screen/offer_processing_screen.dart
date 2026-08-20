import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/views/category_screen/offer_result_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// There's no seller-side app to actually act on an offer (p_seller /
/// vendor_id are unlinked strings, confirmed — no seller auth exists),
/// so acceptance/rejection is simulated client-side after a short delay
/// and written back onto the same offer doc for consistency.
class OfferProcessingScreen extends StatefulWidget {
  final dynamic data;
  final num offerAmount;
  final String offerDocId;
  const OfferProcessingScreen({
    super.key,
    required this.data,
    required this.offerAmount,
    required this.offerDocId,
  });

  @override
  State<OfferProcessingScreen> createState() => _OfferProcessingScreenState();
}

class _OfferProcessingScreenState extends State<OfferProcessingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _resolve);
  }

  Future<void> _resolve() async {
    final accepted = Random().nextDouble() < 0.65;
    await firestore.collection(offersCollection).doc(widget.offerDocId).update({
      'status': accepted ? 'accepted' : 'rejected',
    });
    if (!mounted) return;
    Get.off(() => OfferResultScreen(
          data: widget.data,
          offerAmount: widget.offerAmount,
          offerDocId: widget.offerDocId,
          accepted: accepted,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: makeAnOffer.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: lightGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, size: 56, color: darkFontGrey),
              ),
              28.heightBox,
              offerBeingProcessed.text.center.fontFamily(bold).size(20).color(darkFontGrey).make(),
              12.heightBox,
              offerBeingProcessedBody.text.center.color(fontGrey).size(14).make(),
              40.heightBox,
              ourButton(
                title: backToHome,
                outlined: true,
                color: textfieldGrey,
                onPress: () => Get.until((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/views/category_screen/offer_processing_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class MakeOfferScreen extends StatefulWidget {
  final dynamic data;
  const MakeOfferScreen({super.key, required this.data});

  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  late num offerAmount;
  late TextEditingController controller;
  late num originalPrice;

  @override
  void initState() {
    super.initState();
    originalPrice = num.parse(widget.data['p_price'].toString());
    offerAmount = originalPrice;
    controller = TextEditingController(text: offerAmount.toString());
  }

  List<num> get _quickOffers => List.generate(9, (i) => originalPrice - (500 * (i + 1)));

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
            children: [
              20.heightBox,
              enterOfferAmount.text.center.color(fontGrey).size(14).make(),
              20.heightBox,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: darkFontGrey, width: 1.5),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: extraBold, fontSize: 26, color: darkFontGrey),
                  decoration: const InputDecoration(border: InputBorder.none, prefixText: "\$"),
                  onChanged: (value) => setState(() => offerAmount = num.tryParse(value) ?? 0),
                ),
              ),
              16.heightBox,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _quickOffers.map((value) {
                  final selected = offerAmount == value;
                  return GestureDetector(
                    onTap: () => setState(() {
                      offerAmount = value;
                      controller.text = "$value";
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? primaryColor : whiteColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? primaryColor : textfieldGrey,
                          width: 1.5,
                        ),
                      ),
                      child: "$value".numCurrency.text
                          .color(selected ? whiteColor : darkFontGrey)
                          .fontFamily(semibold)
                          .size(13)
                          .make(),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              ourButton(
                title: sendOffer,
                color: primaryColor,
                textColor: whiteColor,
                onPress: offerAmount > 0
                    ? () async {
                        final offerDoc = await firestore.collection(offersCollection).add({
                          'product_id': widget.data.id,
                          'product_name': widget.data['p_name'],
                          'product_img': widget.data['p_imgs'][0],
                          'p_seller': widget.data['p_seller'],
                          'vendor_id': widget.data['vendor_id'],
                          'buyer_id': currentUser!.uid,
                          'original_price': originalPrice,
                          'offer_amount': offerAmount,
                          'status': 'pending',
                          'created_on': FieldValue.serverTimestamp(),
                        });
                        // ignore: use_build_context_synchronously
                        Get.to(() => OfferProcessingScreen(
                              data: widget.data,
                              offerAmount: offerAmount,
                              offerDocId: offerDoc.id,
                            ));
                      }
                    : null,
              ),
              20.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

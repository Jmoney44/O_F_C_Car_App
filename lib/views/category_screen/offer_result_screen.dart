import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/product_controller.dart';
import 'package:ofcluxury_app/views/cart_screen/cart_screen.dart';
import 'package:ofcluxury_app/views/category_screen/make_offer_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class OfferResultScreen extends StatelessWidget {
  final dynamic data;
  final num offerAmount;
  final String offerDocId;
  final bool accepted;

  const OfferResultScreen({
    super.key,
    required this.data,
    required this.offerAmount,
    required this.offerDocId,
    required this.accepted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "Your Offer".text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: accepted ? primaryColor : lightGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  accepted ? Icons.check_rounded : Icons.sentiment_dissatisfied_rounded,
                  size: 56,
                  color: accepted ? whiteColor : darkFontGrey,
                ),
              ),
              28.heightBox,
              (accepted ? offerAccepted : offerRejected)
                  .text
                  .center
                  .fontFamily(bold)
                  .size(20)
                  .color(darkFontGrey)
                  .make(),
              12.heightBox,
              (accepted
                      ? "Your offer has been accepted by the seller for ${"$offerAmount".numCurrency}"
                      : offerRejectedBody)
                  .text
                  .center
                  .color(fontGrey)
                  .size(14)
                  .make(),
              40.heightBox,
              ourButton(
                title: accepted ? proceedToCheckout : makeOfferAgain,
                color: primaryColor,
                textColor: whiteColor,
                onPress: () {
                  if (accepted) {
                    final controller = Get.put(ProductController());
                    controller.addToCart(
                      title: data['p_name'],
                      img: data['p_imgs'][0],
                      sellername: data['p_seller'],
                      color: (data['p_colors'] as List).isNotEmpty ? data['p_colors'][0] : 0,
                      qty: 1,
                      tprice: offerAmount,
                      vendorID: data['vendor_id'],
                      productId: data.id,
                      context: context,
                    );
                    Get.off(() => const CartScreen());
                  } else {
                    Get.off(() => MakeOfferScreen(data: data));
                  }
                },
              ),
              12.heightBox,
              ourButton(
                title: backToHome,
                outlined: true,
                color: textfieldGrey,
                onPress: () => Get.until((route) => route.isFirst),
              ),
              20.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

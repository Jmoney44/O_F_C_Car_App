import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/cart_controller.dart';
import 'package:ofcluxury_app/views/cart_screen/checkout_review_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// Prices/ETAs are static placeholders (no real shipping-rate API),
/// matching the design reference which also hardcodes these.
class ChooseShippingScreen extends StatelessWidget {
  const ChooseShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: chooseShipping.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              16.heightBox,
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: shippingOptionNames.length,
                    separatorBuilder: (_, __) => 10.heightBox,
                    itemBuilder: (context, index) {
                      final selected = controller.shippingMethodIndex.value == index;
                      return GestureDetector(
                        onTap: () => controller.selectShippingMethod(index),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? primaryColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(shippingOptionIcons[index], color: whiteColor, size: 20),
                              ),
                              12.widthBox,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    shippingOptionNames[index]
                                        .text
                                        .fontFamily(semibold)
                                        .color(darkFontGrey)
                                        .make(),
                                    4.heightBox,
                                    shippingOptionEtas[index].text.color(fontGrey).size(12).make(),
                                  ],
                                ),
                              ),
                              "${shippingOptionPrices[index]}".numCurrency.text
                                  .fontFamily(semibold)
                                  .color(darkFontGrey)
                                  .make(),
                              8.widthBox,
                              Icon(
                                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: selected ? primaryColor : textfieldGrey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Obx(() => ourButton(
                    title: "Apply",
                    color: primaryColor,
                    textColor: whiteColor,
                    onPress: controller.shippingMethodIndex.value >= 0
                        ? () => Get.to(() => const CheckoutReviewScreen())
                        : null,
                  )),
              16.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

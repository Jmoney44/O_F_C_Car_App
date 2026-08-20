import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/cart_controller.dart';
import 'package:ofcluxury_app/views/cart_screen/choose_shipping_screen.dart';
import 'package:ofcluxury_app/views/cart_screen/payment_method.dart';
import 'package:ofcluxury_app/views/cart_screen/shipping_address_list_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class CheckoutReviewScreen extends StatelessWidget {
  const CheckoutReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: checkout.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shippingAddress.text.fontFamily(bold).size(15).color(darkFontGrey).make(),
              10.heightBox,
              Obx(() => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: darkFontGrey),
                        12.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              controller.selectedAddressLabel.value
                                  .text
                                  .fontFamily(semibold)
                                  .color(darkFontGrey)
                                  .make(),
                              4.heightBox,
                              controller.selectedAddressDetails.value.text
                                  .color(fontGrey)
                                  .size(12)
                                  .make(),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_outlined, color: darkFontGrey, size: 18).onTap(() {
                          Get.to(() => const ShippingAddressListScreen());
                        }),
                      ],
                    ),
                  )),
              20.heightBox,
              chooseShipping.text.fontFamily(bold).size(15).color(darkFontGrey).make(),
              10.heightBox,
              Obx(() => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: darkFontGrey),
                        12.widthBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (controller.shippingMethodName.isEmpty
                                      ? "Not selected"
                                      : controller.shippingMethodName)
                                  .text
                                  .fontFamily(semibold)
                                  .color(darkFontGrey)
                                  .make(),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_outlined, color: darkFontGrey, size: 18).onTap(() {
                          Get.to(() => const ChooseShippingScreen());
                        }),
                      ],
                    ),
                  )),
              20.heightBox,
              Obx(() => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _row(amount, "${controller.totalP.value}".numCurrency),
                        8.heightBox,
                        _row(shipping, "${controller.shippingCost}".numCurrency),
                        8.heightBox,
                        _row(tax, "${controller.taxAmount}".numCurrency),
                        const Divider(height: 24, color: textfieldGrey),
                        _row(total, "${controller.grandTotal}".numCurrency, emphasize: true),
                      ],
                    ),
                  )),
              20.heightBox,
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(() => ourButton(
                title: continueToPayment,
                color: primaryColor,
                textColor: whiteColor,
                onPress: controller.shippingMethodIndex.value >= 0
                    ? () => Get.to(() => const PaymentMethods())
                    : null,
              )),
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

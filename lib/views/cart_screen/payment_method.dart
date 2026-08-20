import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/cart_controller.dart';
import 'package:ofcluxury_app/controllers/wallet_controller.dart';
import 'package:ofcluxury_app/views/home_screen/home.dart';
import 'package:ofcluxury_app/views/widgets_common/account_ready_dialog.dart';
import 'package:ofcluxury_app/views/widgets_common/enter_pin_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CartController>();
    var walletController = Get.put(WalletController());

    return Obx(
      () => Scaffold(
        backgroundColor: whiteColor,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: controller.placingOrder.value
                ? Center(
                    child: loadingIndicator(),
                  )
                : ourButton(
                    onPress: () {
                      Get.to(() => EnterPinScreen(
                            instruction: enterPinToConfirmPayment,
                            onVerified: () => _placeOrder(context, controller, walletController),
                          ));
                    },
                    color: primaryColor,
                    textColor: whiteColor,
                    title: "Place my order",
                  ),
          ),
        ),
        appBar: AppBar(
          title: paymentMethodsTitle.text.fontFamily(bold).color(darkFontGrey).make(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              selectPaymentMethod.text.color(fontGrey).make(),
              16.heightBox,
              Obx(
                () => Column(
                  children: List.generate(paymentMethodsImg.length, (index) {
                    final selected = controller.paymentIndex.value == index;
                    return GestureDetector(
                      onTap: () {
                        controller.changePaymentIndex(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: whiteColor,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(paymentMethodsImg[index], fit: BoxFit.contain),
                            ),
                            14.widthBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  paymentMethods[index]
                                      .text
                                      .fontFamily(semibold)
                                      .color(darkFontGrey)
                                      .make(),
                                  if (index == 0)
                                    StreamBuilder<num>(
                                      stream: walletController.balanceStream(),
                                      builder: (context, snapshot) {
                                        final balance = snapshot.data ?? 0;
                                        return "Balance: ${"$balance".numCurrency}"
                                            .text
                                            .color(fontGrey)
                                            .size(12)
                                            .make();
                                      },
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              selected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: selected ? primaryColor : textfieldGrey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartController controller,
    WalletController walletController,
  ) async {
    final methodLabel = paymentMethods[controller.paymentIndex.value];

    // Only "My Wallet" is a real, working payment method — every other
    // option here stays a label, same as before this feature was added.
    if (controller.paymentIndex.value == 0) {
      final success = await walletController.debit(
        controller.grandTotal,
        title: "Order Payment",
      );
      if (!success) {
        // ignore: use_build_context_synchronously
        VxToast.show(context, msg: insufficientBalance);
        Get.back();
        return;
      }
    }

    await controller.placeMyOrder(orderPaymentMethod: methodLabel);
    controller.clearCart();
    if (!context.mounted) return;
    await showAccountReadyDialog(
      context,
      icon: Icons.shopping_cart_rounded,
      title: orderSuccessful,
      body: orderSuccessBody,
    );
    Get.offAll(() => const Home());
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/wallet_controller.dart';
import 'package:ofcluxury_app/views/widgets_common/account_ready_dialog.dart';
import 'package:ofcluxury_app/views/widgets_common/enter_pin_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

// Excludes "My Wallet" itself — you can't top up the wallet from the wallet.
const _methodIcons = [Icons.paypal, Icons.g_mobiledata_rounded, Icons.apple];
const _methodNames = ["PayPal", "Google Pay", "Apple Pay"];

class TopUpPaymentMethodScreen extends StatefulWidget {
  final num amount;
  const TopUpPaymentMethodScreen({super.key, required this.amount});

  @override
  State<TopUpPaymentMethodScreen> createState() => _TopUpPaymentMethodScreenState();
}

class _TopUpPaymentMethodScreenState extends State<TopUpPaymentMethodScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: topUpEWallet.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              12.heightBox,
              topUpMethod.text.color(fontGrey).make(),
              20.heightBox,
              ...List.generate(_methodNames.length, (index) {
                final isSelected = selected == index;
                return GestureDetector(
                  onTap: () => setState(() => selected = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_methodIcons[index], color: darkFontGrey),
                        14.widthBox,
                        Expanded(
                          child: _methodNames[index]
                              .text
                              .fontFamily(semibold)
                              .color(darkFontGrey)
                              .make(),
                        ),
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? primaryColor : textfieldGrey,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              ourButton(
                title: continueStr,
                color: primaryColor,
                textColor: whiteColor,
                onPress: () {
                  Get.to(() => EnterPinScreen(
                        instruction: enterPinToConfirmTopUp,
                        onVerified: () async {
                          await controller.topUp(widget.amount);
                          if (!context.mounted) return;
                          await showAccountReadyDialog(
                            context,
                            icon: Icons.account_balance_wallet_rounded,
                            title: topUpSuccessful,
                            body:
                                "You have successfully topped up your e-wallet for ${"${widget.amount}".numCurrency}",
                          );
                          Get.until((route) => route.isFirst);
                        },
                      ));
                },
              ),
              20.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

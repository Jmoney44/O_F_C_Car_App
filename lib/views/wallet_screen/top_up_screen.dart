import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/wallet_screen/top_up_payment_method_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

const _quickAmounts = [10000, 50000, 100000, 150000, 200000, 250000, 500000, 750000, 1000000];

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  num amount = 100000;
  final controller = TextEditingController(text: "100000");

  @override
  Widget build(BuildContext context) {
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
              24.heightBox,
              enterTopUpAmount.text.center.color(fontGrey).size(14).make(),
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
                  style: TextStyle(fontFamily: extraBold, fontSize: 28, color: darkFontGrey),
                  decoration: const InputDecoration(border: InputBorder.none, prefixText: "\$"),
                  onChanged: (value) => setState(() => amount = num.tryParse(value) ?? 0),
                ),
              ),
              20.heightBox,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _quickAmounts.map((value) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      amount = value;
                      controller.text = "$value";
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: amount == value ? primaryColor : whiteColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: amount == value ? primaryColor : textfieldGrey,
                          width: 1.5,
                        ),
                      ),
                      child: "$value".numCurrency.text
                          .color(amount == value ? whiteColor : darkFontGrey)
                          .fontFamily(semibold)
                          .size(13)
                          .make(),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              ourButton(
                title: continueStr,
                color: primaryColor,
                textColor: whiteColor,
                onPress: amount > 0
                    ? () => Get.to(() => TopUpPaymentMethodScreen(amount: amount))
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

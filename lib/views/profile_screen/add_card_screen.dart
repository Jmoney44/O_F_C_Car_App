import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// Only the last 4 digits, brand, and expiry are ever persisted — the
/// full card number and CVV never leave this screen / are never stored.
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  var isSaving = false;

  @override
  void initState() {
    super.initState();
    // Live card preview refresh as the user types.
    for (final c in [nameController, numberController, expiryController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final digitsOnly = numberController.text.replaceAll(RegExp(r'\D'), '');
    final last4 = digitsOnly.length >= 4 ? digitsOnly.substring(digitsOnly.length - 4) : digitsOnly;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: addNewCard.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkFontGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "•••• •••• •••• ${last4.isEmpty ? '0000' : last4}"
                        .text
                        .color(whiteColor)
                        .size(18)
                        .make(),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (nameController.text.isEmpty ? cardName : nameController.text)
                            .text
                            .color(whiteColor.withValues(alpha: 0.8))
                            .size(13)
                            .make(),
                        (expiryController.text.isEmpty ? "••/••" : expiryController.text)
                            .text
                            .color(whiteColor.withValues(alpha: 0.8))
                            .size(13)
                            .make(),
                      ],
                    ),
                  ],
                ),
              ),
              20.heightBox,
              cardName.text.fontFamily(semibold).size(13).color(darkFontGrey).make(),
              8.heightBox,
              customTextField(hint: cardName, isPass: false, controller: nameController),
              cardNumber.text.fontFamily(semibold).size(13).color(darkFontGrey).make(),
              8.heightBox,
              customTextField(
                hint: "1234 5678 9012 3456",
                isPass: false,
                controller: numberController,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        expiryDate.text.fontFamily(semibold).size(13).color(darkFontGrey).make(),
                        8.heightBox,
                        customTextField(hint: "MM/YY", isPass: false, controller: expiryController),
                      ],
                    ),
                  ),
                  12.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cvv.text.fontFamily(semibold).size(13).color(darkFontGrey).make(),
                        8.heightBox,
                        customTextField(
                          hint: "699",
                          isPass: false,
                          controller: cvvController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              20.heightBox,
              isSaving
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(primaryColor),
                      ),
                    )
                  : ourButton(
                      title: addAndUse,
                      color: primaryColor,
                      textColor: whiteColor,
                      onPress: () async {
                        if (nameController.text.trim().isEmpty || last4.length < 4) {
                          VxToast.show(context, msg: "Please fill in a valid card");
                          return;
                        }
                        setState(() => isSaving = true);
                        await FirestoreServices.addCard(
                          cardName: nameController.text.trim(),
                          last4: last4,
                          brand: "Card",
                          expiry: expiryController.text.trim(),
                        );
                        numberController.clear();
                        cvvController.clear();
                        if (!context.mounted) return;
                        Get.back();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

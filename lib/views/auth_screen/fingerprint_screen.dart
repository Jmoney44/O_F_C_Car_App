import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/home_screen/home.dart';
import 'package:ofcluxury_app/views/widgets_common/account_ready_dialog.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// Visual-only biometric setup step shown once after signup. There is
/// no real biometric plugin wired in, so tapping "Continue" (or "Skip")
/// just advances the setup flow rather than performing an actual scan.
class FingerprintScreen extends StatelessWidget {
  const FingerprintScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    await showAccountReadyDialog(context, icon: Icons.person_rounded);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (context.mounted) Get.offAll(() => const Home());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: setYourFingerprint.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              20.heightBox,
              fingerprintInstruction.text.center.color(fontGrey).size(14).make(),
              const Spacer(),
              const Icon(Icons.fingerprint_rounded, size: 190, color: darkFontGrey),
              const Spacer(),
              fingerprintCta.text.center.color(fontGrey).size(14).make(),
              24.heightBox,
              Row(
                children: [
                  Expanded(
                    child: ourButton(
                      title: skipStr,
                      outlined: true,
                      color: textfieldGrey,
                      onPress: () => _finish(context),
                    ),
                  ),
                  12.widthBox,
                  Expanded(
                    child: ourButton(
                      title: continueStr,
                      color: primaryColor,
                      textColor: whiteColor,
                      onPress: () => _finish(context),
                    ),
                  ),
                ],
              ),
              20.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

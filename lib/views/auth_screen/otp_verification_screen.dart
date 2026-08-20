import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/auth_screen/create_new_password_screen.dart';

/// Visual-only OTP step for the password-reset flow. A real reset link
/// was already emailed by [ForgotPasswordScreen] via Firebase Auth —
/// there's no SMS/OTP backend behind this screen, so the code entered
/// here isn't actually verified against anything.
class OtpVerificationScreen extends StatefulWidget {
  final String maskedContact;
  const OtpVerificationScreen({super.key, required this.maskedContact});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String code = "";
  int secondsLeft = 55;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    secondsLeft = 55;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (code.length < 4) setState(() => code += digit);
  }

  void _removeDigit() {
    if (code.isNotEmpty) setState(() => code = code.substring(0, code.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: forgotPasswordTitle.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            40.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: "$codeSentTo ${widget.maskedContact}"
                  .text
                  .center
                  .color(fontGrey)
                  .size(14)
                  .make(),
            ),
            28.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < code.length;
                return Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: index == code.length ? darkFontGrey : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: filled
                      ? code[index].text.size(20).fontFamily(bold).color(darkFontGrey).make()
                      : null,
                );
              }),
            ),
            16.heightBox,
            (secondsLeft > 0 ? "$resendCodeIn $secondsLeft s" : "Resend code")
                .text
                .color(fontGrey)
                .size(13)
                .make()
                .onTap(secondsLeft == 0 ? _startTimer : null),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: code.length == 4 ? primaryColor : textfieldGrey,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: code.length == 4
                      ? () => Get.to(() => const CreateNewPasswordScreen())
                      : null,
                  child: verify.text.fontFamily(bold).color(whiteColor).size(16).make(),
                ),
              ),
            ),
            _NumberPad(onDigit: _addDigit, onBackspace: _removeDigit),
            20.heightBox,
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumberPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["*", "0", "back"],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows
          .map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == "back") {
                  return SizedBox(
                    width: 72,
                    height: 56,
                    child: IconButton(
                      onPressed: onBackspace,
                      icon: const Icon(Icons.backspace_outlined, color: darkFontGrey),
                    ),
                  );
                }
                if (key == "*") {
                  return const SizedBox(width: 72, height: 56);
                }
                return SizedBox(
                  width: 72,
                  height: 56,
                  child: TextButton(
                    onPressed: () => onDigit(key),
                    child: key.text.size(22).fontFamily(semibold).color(darkFontGrey).make(),
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}

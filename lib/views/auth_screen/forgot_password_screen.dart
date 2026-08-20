import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/auth_controller.dart';
import 'package:ofcluxury_app/views/auth_screen/otp_verification_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// Entry step of the password-reset flow. This still sends a real
/// Firebase password-reset email in the background (so recovery
/// actually works), then continues into the themed OTP screens that
/// match the design reference — those screens are visual-only since
/// there's no SMS backend behind them.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  var controller = Get.put(AuthController());
  var isSending = false;

  String _maskEmail(String value) {
    final parts = value.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return value;
    final name = parts[0];
    final visible = name.length <= 2 ? name : name.substring(0, 2);
    return "$visible***@${parts[1]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: forgotPasswordTitle.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              32.heightBox,
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 52, color: darkFontGrey),
                ),
              ),
              32.heightBox,
              forgotPasswordInstruction.text.color(fontGrey).size(15).make(),
              20.heightBox,
              customTextField(
                hint: emailHint,
                icon: Icons.mail_outline_rounded,
                isPass: false,
                controller: emailController,
              ),
              12.heightBox,
              isSending
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(primaryColor),
                      ),
                    )
                  : ourButton(
                      title: continueStr,
                      color: primaryColor,
                      textColor: whiteColor,
                      onPress: () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          VxToast.show(context, msg: "Please enter your email");
                          return;
                        }
                        setState(() => isSending = true);
                        await controller.resetPassword(email: email, context: context);
                        setState(() => isSending = false);
                        // ignore: use_build_context_synchronously
                        Get.to(() => OtpVerificationScreen(maskedContact: _maskEmail(email)));
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

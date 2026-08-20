import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/auth_screen/login_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/account_ready_dialog.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// Final, visual-only step of the decorative OTP password-reset flow.
/// The real password change already happens through the emailed Firebase
/// reset link sent from [ForgotPasswordScreen]; this screen doesn't call
/// any backend, it just mirrors the design and returns to Login.
class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  var rememberMeChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: createNewPassword.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              24.heightBox,
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_outlined, size: 48, color: darkFontGrey),
                ),
              ),
              28.heightBox,
              Align(
                alignment: Alignment.centerLeft,
                child: createNewPasswordInstruction.text
                    .fontFamily(semibold)
                    .color(darkFontGrey)
                    .size(15)
                    .make(),
              ),
              12.heightBox,
              customTextField(
                hint: password,
                icon: Icons.lock_outline_rounded,
                isPass: true,
                controller: passwordController,
              ),
              customTextField(
                hint: retypePassword,
                icon: Icons.lock_outline_rounded,
                isPass: true,
                controller: confirmController,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      activeColor: primaryColor,
                      checkColor: whiteColor,
                      side: const BorderSide(color: textfieldGrey, width: 1.5),
                      value: rememberMeChecked,
                      onChanged: (value) => setState(() => rememberMeChecked = value ?? false),
                    ),
                  ),
                  8.widthBox,
                  rememberMe.text.color(darkFontGrey).size(14).make(),
                ],
              ),
              24.heightBox,
              ourButton(
                title: continueStr,
                color: primaryColor,
                textColor: whiteColor,
                onPress: () async {
                  if (passwordController.text.isEmpty ||
                      passwordController.text != confirmController.text) {
                    VxToast.show(context, msg: "Passwords don't match");
                    return;
                  }
                  await showAccountReadyDialog(
                    context,
                    icon: Icons.shield_rounded,
                    body: passwordResetSuccess,
                  );
                  await Future.delayed(const Duration(milliseconds: 1400));
                  if (context.mounted) Get.offAll(() => const LoginScreen());
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

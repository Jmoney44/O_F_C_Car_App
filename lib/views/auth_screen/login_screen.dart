import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/auth_controller.dart';
import 'package:ofcluxury_app/views/auth_screen/forgot_password_screen.dart';
import 'package:ofcluxury_app/views/auth_screen/signup_screen.dart';
import 'package:ofcluxury_app/views/home_screen/home.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());

    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: BackButton(color: darkFontGrey, onPressed: () => Get.back()),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Icon(Icons.time_to_leave_rounded, size: 110, color: darkFontGrey),
                24.heightBox,
                "Login to Your Account"
                    .text
                    .center
                    .fontFamily(extraBold)
                    .color(darkFontGrey)
                    .size(24)
                    .make(),
                28.heightBox,
                Obx(
                  () => Column(
                    children: [
                      customTextField(
                          hint: emailHint,
                          icon: Icons.mail_outline_rounded,
                          isPass: false,
                          controller: controller.emailController),
                      customTextField(
                          hint: passwordHint,
                          icon: Icons.lock_outline_rounded,
                          isPass: true,
                          controller: controller.passwordController),
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              activeColor: primaryColor,
                              checkColor: whiteColor,
                              side: const BorderSide(color: textfieldGrey, width: 1.5),
                              value: controller.rememberMe.value,
                              onChanged: (value) => controller.rememberMe(value ?? false),
                            ),
                          ),
                          8.widthBox,
                          rememberMe.text.color(darkFontGrey).size(14).make(),
                        ],
                      ),
                      20.heightBox,
                      controller.isloading.value
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                            )
                          : ourButton(
                              color: primaryColor,
                              title: login,
                              textColor: whiteColor,
                              onPress: () async {
                                controller.isloading(true);

                                await controller
                                    .loginMethod(context: context)
                                    .then((value) {
                                  if (value != null) {
                                    VxToast.show(context, msg: "Logged in");
                                    Get.offAll(() => const Home());
                                  } else {
                                    controller.isloading(false);
                                  }
                                });
                              },
                            ),
                      16.heightBox,
                      forgetPass.text
                          .fontFamily(semibold)
                          .color(darkFontGrey)
                          .size(14)
                          .make()
                          .onTap(() {
                        Get.to(() => const ForgotPasswordScreen());
                      }),
                      28.heightBox,
                      Row(
                        children: [
                          Expanded(child: Divider(color: textfieldGrey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: continueWith.text.color(fontGrey).size(13).make(),
                          ),
                          Expanded(child: Divider(color: textfieldGrey)),
                        ],
                      ),
                      20.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          socialIconList.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 54,
                              height: 54,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: textfieldGrey, width: 1.5),
                              ),
                              child: Image.asset(socialIconList[index]),
                            ),
                          ),
                        ),
                      ),
                      24.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          dontHaveAccount.text.color(fontGrey).make(),
                          signup.text
                              .fontFamily(semibold)
                              .color(darkFontGrey)
                              .make()
                              .onTap(() {
                            Get.to(() => const SignupScreen());
                          }),
                        ],
                      ),
                      20.heightBox,
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

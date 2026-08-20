import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/auth_controller.dart';
import 'package:ofcluxury_app/views/auth_screen/fill_profile_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                "Create Your Account"
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
                          controller: controller.emailController,
                          isPass: false),
                      customTextField(
                          hint: passwordHint,
                          icon: Icons.lock_outline_rounded,
                          controller: controller.passwordController,
                          isPass: true),
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
                      24.heightBox,
                      controller.isloading.value
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                            )
                          : ourButton(
                              color: primaryColor,
                              title: signup,
                              textColor: whiteColor,
                              onPress: () async {
                                controller.isloading(true);
                                try {
                                  final email = controller.emailController.text.trim();
                                  final derivedName = email.contains('@')
                                      ? email.split('@').first
                                      : email;
                                  await controller
                                      .signupMethod(
                                          context: context,
                                          email: email,
                                          password: controller.passwordController.text)
                                      .then((value) {
                                    return controller.storeUserData(
                                        email: email,
                                        password: controller.passwordController.text,
                                        name: derivedName);
                                  }).then((value) {
                                    VxToast.show(context, msg: loggedin);
                                    Get.offAll(() => const FillProfileScreen());
                                  });
                                } catch (e) {
                                  auth.signOut();
                                  // ignore: use_build_context_synchronously
                                  VxToast.show(context, msg: e.toString());
                                  controller.isloading(false);
                                }
                              },
                            ),
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
                          alreadyHaveAccount.text.color(fontGrey).make(),
                          login.text
                              .fontFamily(semibold)
                              .color(darkFontGrey)
                              .make()
                              .onTap(() {
                            Get.back();
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

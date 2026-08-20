import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/views/auth_screen/login_screen.dart';
import 'package:ofcluxury_app/views/auth_screen/signup_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class LetsYouInScreen extends StatelessWidget {
  const LetsYouInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: darkFontGrey, onPressed: () => Get.back()),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                20.heightBox,
                const Icon(Icons.time_to_leave_rounded, size: 120, color: darkFontGrey),
                28.heightBox,
                letsYouIn.text.fontFamily(extraBold).color(darkFontGrey).size(26).make(),
                32.heightBox,
                Column(
                  children: List.generate(
                    socialIconList.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: textfieldGrey, width: 1.5),
                            shape: const StadiumBorder(),
                          ),
                          icon: Image.asset(socialIconList[index], width: 22),
                          label: "Continue with ${socialNameList[index]}"
                              .text
                              .fontFamily(semibold)
                              .color(darkFontGrey)
                              .make(),
                        ),
                      ),
                    ),
                  ),
                ),
                16.heightBox,
                Row(
                  children: [
                    Expanded(child: Divider(color: textfieldGrey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: "or".text.color(fontGrey).size(13).make(),
                    ),
                    Expanded(child: Divider(color: textfieldGrey)),
                  ],
                ),
                16.heightBox,
                ourButton(
                  title: signInWithPassword,
                  color: primaryColor,
                  textColor: whiteColor,
                  onPress: () {
                    Get.to(() => const LoginScreen());
                  },
                ),
                24.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    dontHaveAccount.text.color(fontGrey).make(),
                    signup.text.fontFamily(semibold).color(darkFontGrey).make().onTap(() {
                      Get.to(() => const SignupScreen());
                    }),
                  ],
                ),
                20.heightBox,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/controllers/profile_controller.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final controller = Get.put(ProfileController());
  var isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: changePassword.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              customTextField(
                hint: oldPasswordHint,
                icon: Icons.lock_outline_rounded,
                isPass: true,
                controller: controller.oldpassController,
              ),
              customTextField(
                hint: newPasswordHint,
                icon: Icons.lock_outline_rounded,
                isPass: true,
                controller: controller.newpassController,
              ),
              20.heightBox,
              isSaving
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(primaryColor),
                    )
                  : ourButton(
                      title: continueStr,
                      color: primaryColor,
                      textColor: whiteColor,
                      onPress: () async {
                        if (controller.newpassController.text.trim().length < 6) {
                          VxToast.show(context, msg: "New password must be at least 6 characters");
                          return;
                        }
                        setState(() => isSaving = true);
                        final success = await controller.changeAuthPassword(
                          email: currentUser!.email,
                          password: controller.oldpassController.text,
                          newpassword: controller.newpassController.text,
                        );
                        if (!mounted) return;
                        setState(() => isSaving = false);
                        if (success) {
                          VxToast.show(context, msg: "Password updated");
                          Get.back();
                        } else {
                          VxToast.show(context, msg: "Incorrect old password");
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

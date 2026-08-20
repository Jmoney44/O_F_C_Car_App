import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/auth_controller.dart';
import 'package:ofcluxury_app/views/auth_screen/create_pin_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/change_password_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // Face ID / Biometric ID are decorative — no local_auth dependency is
  // present, so there's no real biometric check to gate.
  var faceIdEnabled = false;
  var biometricIdEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: securityLabel.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() => _toggleRow(
                    rememberMe,
                    authController.rememberMe.value,
                    (v) => authController.rememberMe(v),
                  )),
              _toggleRow(faceId, faceIdEnabled, (v) => setState(() => faceIdEnabled = v)),
              _toggleRow(
                  biometricId, biometricIdEnabled, (v) => setState(() => biometricIdEnabled = v)),
              20.heightBox,
              ourButton(
                title: changePin,
                outlined: true,
                color: textfieldGrey,
                onPress: () => Get.to(() => const CreatePinScreen(standalone: true)),
              ),
              12.heightBox,
              ourButton(
                title: changePassword,
                outlined: true,
                color: textfieldGrey,
                onPress: () => Get.to(() => const ChangePasswordScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          label.text.color(darkFontGrey).make(),
          Switch(
            value: value,
            activeThumbColor: whiteColor,
            activeTrackColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

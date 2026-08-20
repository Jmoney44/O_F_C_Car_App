import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/controllers/profile_controller.dart';
import 'package:ofcluxury_app/views/auth_screen/create_pin_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class FillProfileScreen extends StatefulWidget {
  const FillProfileScreen({super.key});

  @override
  State<FillProfileScreen> createState() => _FillProfileScreenState();
}

class _FillProfileScreenState extends State<FillProfileScreen> {
  final controller = Get.put(ProfileController());
  final fullNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  DateTime? dob;
  String selectedGender = "Male";
  var isSaving = false;

  @override
  void initState() {
    super.initState();
    fullNameController.text = currentUser?.displayName ?? '';
    emailController.text = currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: fillYourProfile.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              20.heightBox,
              Center(
                child: Obx(
                  () => Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: lightGrey,
                        backgroundImage: controller.profileImgPath.value.isNotEmpty
                            ? FileImage(File(controller.profileImgPath.value))
                            : null,
                        child: controller.profileImgPath.value.isEmpty
                            ? const Icon(Icons.person, size: 40, color: fontGrey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: whiteColor),
                        ).onTap(() => controller.changeImage(context)),
                      ),
                    ],
                  ),
                ),
              ),
              28.heightBox,
              customTextField(
                hint: fullName,
                icon: Icons.person_outline_rounded,
                isPass: false,
                controller: fullNameController,
              ),
              customTextField(
                hint: nickname,
                icon: Icons.badge_outlined,
                isPass: false,
                controller: nicknameController,
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1930),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => dob = picked);
                },
                child: AbsorbPointer(
                  child: customTextField(
                    hint: dob == null ? dateOfBirth : intl.DateFormat.yMd().format(dob!),
                    icon: Icons.calendar_today_outlined,
                    isPass: false,
                  ),
                ),
              ),
              AbsorbPointer(
                child: customTextField(
                  hint: email,
                  icon: Icons.mail_outline_rounded,
                  isPass: false,
                  controller: emailController,
                ),
              ),
              Row(
                children: [
                  "🇺🇸".text.size(20).make(),
                  6.widthBox,
                  const Icon(Icons.arrow_drop_down, color: fontGrey),
                  10.widthBox,
                  Expanded(
                    child: customTextField(
                      hint: phoneNumber,
                      isPass: false,
                      controller: phoneController,
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  fillColor: lightGrey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGender = value ?? selectedGender),
              ),
              24.heightBox,
              isSaving
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(primaryColor),
                    )
                  : ourButton(
                      title: continueStr,
                      color: primaryColor,
                      textColor: whiteColor,
                      onPress: () async {
                        setState(() => isSaving = true);
                        try {
                          if (controller.profileImgPath.value.isNotEmpty) {
                            await controller.uploadProfileImage();
                          }
                          await firestore
                              .collection(usersCollection)
                              .doc(currentUser!.uid)
                              .set({
                            if (fullNameController.text.trim().isNotEmpty)
                              'name': fullNameController.text.trim(),
                            'nickname': nicknameController.text.trim(),
                            'dob': dob?.toIso8601String() ?? '',
                            'phone': phoneController.text.trim(),
                            'gender': selectedGender,
                            if (controller.profileImageLink.isNotEmpty)
                              'imageUrl': controller.profileImageLink,
                          }, SetOptions(merge: true));
                        } finally {
                          if (mounted) {
                            setState(() => isSaving = false);
                            Get.to(() => const CreatePinScreen());
                          }
                        }
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

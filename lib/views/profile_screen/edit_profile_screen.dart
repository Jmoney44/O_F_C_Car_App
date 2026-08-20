import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/profile_controller.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class EditProfileScreen extends StatelessWidget {
  final dynamic data;

  const EditProfileScreen({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<ProfileController>();

    return bgWidget(
        child: Scaffold(
      appBar: AppBar(
        title: "Edit Profile".text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //if data image url and controller path is empty
              data['imageUrl'] == '' && controller.profileImgPath.isEmpty
                  ? Image.asset(imgProfile2, width: 96, height: 96, fit: BoxFit.cover)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make()

                  // if data is not empty but controller path is empty
                  : data['imageUrl'] != '' && controller.profileImgPath.isEmpty
                      ? Image.network(
                          data['imageUrl'],
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ).box.roundedFull.clip(Clip.antiAlias).make()

                      //else if controller path is not empty but data image url is
                      : Image.file(
                          File(controller.profileImgPath.value),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ).box.roundedFull.clip(Clip.antiAlias).make(),
              12.heightBox,
              "Change photo".text.fontFamily(semibold).color(darkFontGrey).make().onTap(() {
                controller.changeImage(context);
              }),
              24.heightBox,
              customTextField(
                controller: controller.nameController,
                hint: nameHint,
                title: name,
                icon: Icons.person_outline_rounded,
                isPass: false,
              ),
              customTextField(
                controller: controller.oldpassController,
                hint: passwordHint,
                title: oldpass,
                icon: Icons.lock_outline_rounded,
                isPass: true,
              ),
              customTextField(
                controller: controller.newpassController,
                hint: passwordHint,
                title: newpass,
                icon: Icons.lock_outline_rounded,
                isPass: true,
              ),
              12.heightBox,
              controller.isloading.value
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(primaryColor),
                    )
                  : ourButton(
                      color: primaryColor,
                      onPress: () async {
                        controller.isloading(true);

                        //if image is not selected
                        if (controller.profileImgPath.value.isNotEmpty) {
                          await controller.uploadProfileImage();
                        } else {
                          controller.profileImageLink = data['imageUrl'];
                        }

                        //if old password matches data base
                        if (data['password'] ==
                            controller.oldpassController.text) {
                          await controller.changeAuthPassword(
                              email: data['email'],
                              password: controller.oldpassController.text,
                              newpassword: controller.newpassController.text);

                          await controller.updateProfile(
                              imgUrl: controller.profileImageLink,
                              name: controller.nameController.text,
                              password: controller.newpassController.text);
                          // ignore: use_build_context_synchronously
                          VxToast.show(context, msg: "Updated");
                        } else {
                          // ignore: use_build_context_synchronously
                          VxToast.show(context, msg: "Wrong Old Password");
                          controller.isloading(false);
                        }
                      },
                      textColor: whiteColor,
                      title: "Save"),
              20.heightBox,
            ],
          ),
        ),
      ),
    ));
  }
}

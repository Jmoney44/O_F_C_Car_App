import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// Themed full-screen call UI. There's no audio/video SDK wired in —
/// the controls are decorative and "hang up" just pops the screen.
class CallScreen extends StatelessWidget {
  final String name;
  const CallScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkFontGrey,
      body: SafeArea(
        child: Column(
          children: [
            60.heightBox,
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: lightGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront_rounded, size: 56, color: darkFontGrey),
            ),
            20.heightBox,
            name.text.fontFamily(bold).size(20).color(whiteColor).make(),
            8.heightBox,
            "Calling...".text.color(whiteColor.withValues(alpha: 0.6)).make(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _callButton(icon: Icons.close_rounded, onTap: () => Get.back()),
                24.widthBox,
                _callButton(icon: Icons.videocam_outlined, onTap: () {}),
                24.widthBox,
                _callButton(icon: Icons.volume_up_outlined, onTap: () {}),
              ],
            ),
            40.heightBox,
          ],
        ),
      ),
    );
  }

  Widget _callButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF3A3D45),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: whiteColor),
    ).onTap(onTap);
  }
}

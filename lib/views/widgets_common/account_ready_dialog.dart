import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// Shared "Congratulations!" success modal shown at the end of a setup
/// flow (post-signup security steps, password reset). [icon] varies by
/// context; body copy stays consistent with the design reference.
Future<void> showAccountReadyDialog(
  BuildContext context, {
  IconData icon = Icons.check_circle_rounded,
  String title = accountReadyTitle,
  String body = accountReadyBody,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: whiteColor, size: 44),
            ),
            20.heightBox,
            title.text.fontFamily(bold).size(18).color(darkFontGrey).make(),
            10.heightBox,
            body.text.center.color(fontGrey).size(14).make(),
            20.heightBox,
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

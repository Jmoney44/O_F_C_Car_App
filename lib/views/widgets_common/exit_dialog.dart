import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

Widget exitDialog(context) {
  return Dialog(
    backgroundColor: whiteColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        "Confirm".text.fontFamily(bold).size(18).color(darkFontGrey).make(),
        8.heightBox,
        "Are you sure you want to exit?"
            .text
            .size(15)
            .color(fontGrey)
            .make(),
        20.heightBox,
        Row(
          children: [
            Expanded(
              child: ourButton(
                  outlined: true,
                  color: darkFontGrey,
                  onPress: () {
                    Navigator.pop(context);
                  },
                  title: "No"),
            ),
            12.widthBox,
            Expanded(
              child: ourButton(
                  color: primaryColor,
                  onPress: () {
                    SystemNavigator.pop();
                  },
                  textColor: whiteColor,
                  title: "Yes"),
            ),
          ],
        ),
      ],
    ).box.padding(const EdgeInsets.all(20)).make(),
  );
}

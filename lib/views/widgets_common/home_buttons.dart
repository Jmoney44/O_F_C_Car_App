import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget homeButtons({width, height, icon, String? title, onPress}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(icon, width: 26),
      10.heightBox,
      title!.text.fontFamily(semibold).size(13).color(darkFontGrey).make()
    ],
  ).box
      .withRounded(value: 16)
      .color(lightGrey)
      .size(width, height)
      .make()
      .onTap(onPress);
}

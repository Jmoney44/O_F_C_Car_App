import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget detailsCard({width, String? count, String? title}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      count!.text.fontFamily(bold).color(darkFontGrey).size(18).make(),
      4.heightBox,
      title!.text.color(fontGrey).size(11).align(TextAlign.center).make(),
    ],
  )
      .box
      .color(lightGrey)
      .withRounded(value: 16)
      .width(width)
      .height(80)
      .padding(const EdgeInsets.all(4))
      .make();
}

import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget ourButton({onPress, color, textColor, String? title}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      // ignore: deprecated_member_use
      backgroundColor: color,
      padding: const EdgeInsets.all(12),
    ),
    onPressed: onPress,
    child: title!.text.color(textColor).fontFamily(bold).make(),
  );
}

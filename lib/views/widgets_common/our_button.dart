import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget ourButton({
  onPress,
  Color? color,
  Color? textColor,
  String? title,
  bool outlined = false,
}) {
  final Color background = outlined ? whiteColor : (color ?? primaryColor);
  final Color foreground =
      outlined ? (color ?? primaryColor) : (textColor ?? whiteColor);

  return SizedBox(
    height: 54,
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        shadowColor: Colors.transparent,
        disabledBackgroundColor: textfieldGrey,
        shape: StadiumBorder(
          side: outlined
              ? BorderSide(color: color ?? textfieldGrey, width: 1.5)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      onPressed: onPress,
      child: title!.text.color(foreground).fontFamily(bold).size(16).make(),
    ),
  );
}

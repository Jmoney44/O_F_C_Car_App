import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget customTextField({
  String? title,
  String? hint,
  controller,
  isPass,
  IconData? icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null && title.isNotEmpty) ...[
        title.text.color(darkFontGrey).fontFamily(semibold).size(14).make(),
        6.heightBox,
      ],
      TextFormField(
        obscureText: isPass ?? false,
        controller: controller,
        style: TextStyle(fontFamily: regular, color: darkFontGrey),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: fontGrey) : null,
          hintStyle: TextStyle(
            fontFamily: regular,
            color: fontGrey,
          ),
          hintText: hint,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          fillColor: lightGrey,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: darkFontGrey, width: 1.5),
          ),
        ),
      ),
      12.heightBox,
    ],
  );
}

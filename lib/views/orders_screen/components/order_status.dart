import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget orderStatus({icon, title, showDone}) {
  final Color color = showDone == true ? primaryColor : textfieldGrey;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    ),
    title: "$title".text.color(darkFontGrey).fontFamily(semibold).make(),
    trailing: showDone == true
        ? const Icon(Icons.check_circle, color: primaryColor)
        : Icon(Icons.circle_outlined, color: textfieldGrey),
  );
}

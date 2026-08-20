import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// Selectable pill-shaped filter chip (brand/category/sort rows).
Widget pillChip({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? primaryColor : whiteColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: selected ? primaryColor : textfieldGrey,
          width: 1.5,
        ),
      ),
      child: label.text
          .fontFamily(semibold)
          .size(13)
          .color(selected ? whiteColor : darkFontGrey)
          .make(),
    ),
  );
}

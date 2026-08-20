import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// "Title" + "See All" row used above product sections app-wide.
Widget sectionHeader({required String title, String seeAllText = "See All", VoidCallback? onSeeAll}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      title.text.fontFamily(bold).size(17).color(darkFontGrey).make(),
      if (onSeeAll != null)
        seeAllText.text.fontFamily(semibold).size(13).color(fontGrey).make().onTap(onSeeAll),
    ],
  );
}

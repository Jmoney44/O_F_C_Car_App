import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

Widget applogoWidget() {
  //using velocity X here
  return Image.asset(icOfcLogo).box.white.size(77, 77).padding(const EdgeInsets.all(8)).rounded.make();
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/widgets_common/custom_textfield.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// No Maps SDK/API key is available in this project, so the map is a
/// static placeholder graphic rather than a live interactive map.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final labelController = TextEditingController();
  final detailsController = TextEditingController();
  var makeDefault = false;
  var isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: addNewAddress.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: lightGrey,
            child: CustomPaint(
              painter: _GridPainter(),
              child: const Center(
                child: Icon(Icons.location_on, size: 40, color: darkFontGrey),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addressDetails.text.fontFamily(bold).size(16).color(darkFontGrey).make(),
                  16.heightBox,
                  nameAddress.text.color(fontGrey).size(13).make(),
                  8.heightBox,
                  customTextField(hint: "Hotel", isPass: false, controller: labelController),
                  8.heightBox,
                  addressDetails.text.color(fontGrey).size(13).make(),
                  8.heightBox,
                  customTextField(
                      hint: "2899 Summer Drive Taylor, PC 48180",
                      icon: Icons.location_on_outlined,
                      isPass: false,
                      controller: detailsController),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          activeColor: primaryColor,
                          checkColor: whiteColor,
                          side: const BorderSide(color: textfieldGrey, width: 1.5),
                          value: makeDefault,
                          onChanged: (value) => setState(() => makeDefault = value ?? false),
                        ),
                      ),
                      8.widthBox,
                      makeDefaultAddress.text.color(darkFontGrey).size(13).make(),
                    ],
                  ),
                  20.heightBox,
                  isSaving
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(primaryColor),
                          ),
                        )
                      : ourButton(
                          title: addAndUse,
                          color: primaryColor,
                          textColor: whiteColor,
                          onPress: () async {
                            if (labelController.text.trim().isEmpty ||
                                detailsController.text.trim().isEmpty) {
                              VxToast.show(context, msg: "Please fill in both fields");
                              return;
                            }
                            setState(() => isSaving = true);
                            await FirestoreServices.addAddress(
                              label: labelController.text.trim(),
                              details: detailsController.text.trim(),
                              isDefault: makeDefault,
                            );
                            if (!context.mounted) return;
                            Get.back();
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = textfieldGrey
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

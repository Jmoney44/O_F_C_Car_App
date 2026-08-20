import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String? productId;
  final String productTitle;
  final String? productImg;

  const LeaveReviewScreen({
    super.key,
    required this.productId,
    required this.productTitle,
    this.productImg,
  });

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  int rating = 0;
  final commentController = TextEditingController();
  var isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: leaveAReview.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.productImg != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(widget.productImg!, height: 90, fit: BoxFit.cover),
                ),
                12.heightBox,
              ],
              widget.productTitle.text.fontFamily(semibold).color(darkFontGrey).make(),
              24.heightBox,
              howIsYourCar.text.fontFamily(bold).size(16).color(darkFontGrey).make(),
              8.heightBox,
              reviewHint.text.center.color(fontGrey).size(13).make(),
              16.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 32,
                    color: index < rating ? golden : textfieldGrey,
                  ).onTap(() => setState(() => rating = index + 1));
                }),
              ),
              16.heightBox,
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: reviewHint,
                  hintStyle: TextStyle(fontFamily: regular, color: fontGrey),
                  filled: true,
                  fillColor: lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ourButton(
                      title: cancel,
                      outlined: true,
                      color: textfieldGrey,
                      onPress: () => Get.back(),
                    ),
                  ),
                  12.widthBox,
                  Expanded(
                    child: isSubmitting
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(primaryColor),
                            ),
                          )
                        : ourButton(
                            title: submit,
                            color: primaryColor,
                            textColor: whiteColor,
                            onPress: rating == 0
                                ? null
                                : () async {
                                    if (widget.productId == null) {
                                      VxToast.show(context,
                                          msg: "This order predates review support");
                                      Get.back();
                                      return;
                                    }
                                    setState(() => isSubmitting = true);
                                    await FirestoreServices.addReview(
                                      productId: widget.productId!,
                                      rating: rating,
                                      comment: commentController.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    VxToast.show(context, msg: "Review submitted");
                                    Get.back();
                                  },
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

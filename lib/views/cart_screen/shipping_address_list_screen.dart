import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/cart_controller.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/cart_screen/add_address_screen.dart';
import 'package:ofcluxury_app/views/cart_screen/choose_shipping_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class ShippingAddressListScreen extends StatelessWidget {
  const ShippingAddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: shippingAddress.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreServices.getAddresses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: loadingIndicator());
              }
              final docs = snapshot.data!.docs;
              return Column(
                children: [
                  16.heightBox,
                  Expanded(
                    child: docs.isEmpty
                        ? "No saved addresses yet".text.color(fontGrey).makeCentered()
                        : ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => 10.heightBox,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              return Obx(() {
                                final selected =
                                    controller.selectedAddressLabel.value == doc['label'] &&
                                        controller.selectedAddressDetails.value == doc['details'];
                                return GestureDetector(
                                  onTap: () => controller.selectAddress(
                                      label: "${doc['label']}", details: "${doc['details']}"),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: lightGrey,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selected ? primaryColor : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, color: darkFontGrey),
                                        12.widthBox,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              "${doc['label']}"
                                                  .text
                                                  .fontFamily(semibold)
                                                  .color(darkFontGrey)
                                                  .make(),
                                              4.heightBox,
                                              "${doc['details']}".text.color(fontGrey).size(12).make(),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          selected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color: selected ? primaryColor : textfieldGrey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                  ),
                  12.heightBox,
                  ourButton(
                    title: addNewAddress,
                    outlined: true,
                    color: textfieldGrey,
                    onPress: () => Get.to(() => const AddAddressScreen()),
                  ),
                  12.heightBox,
                  Obx(() => ourButton(
                        title: continueStr,
                        color: primaryColor,
                        textColor: whiteColor,
                        onPress: controller.selectedAddressDetails.value.isNotEmpty
                            ? () => Get.to(() => const ChooseShippingScreen())
                            : null,
                      )),
                  16.heightBox,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

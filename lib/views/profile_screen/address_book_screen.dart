import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/cart_screen/add_address_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

/// Profile > Address — plain management view (no selection semantics,
/// unlike the checkout flow's address picker which needs CartController).
class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: addressLabel.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreServices.getAddresses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: loadingIndicator());
              }
              final docs = snapshot.data!.docs;
              return Column(
                children: [
                  Expanded(
                    child: docs.isEmpty
                        ? "No saved addresses yet".text.color(fontGrey).makeCentered()
                        : ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => 10.heightBox,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final isDefault = doc['isDefault'] == true;
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: lightGrey,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: darkFontGrey),
                                    12.widthBox,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              "${doc['label']}"
                                                  .text
                                                  .fontFamily(semibold)
                                                  .color(darkFontGrey)
                                                  .make(),
                                              if (isDefault) ...[
                                                8.widthBox,
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: whiteColor,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: defaultAddress.text.size(10).color(fontGrey).make(),
                                                ),
                                              ],
                                            ],
                                          ),
                                          4.heightBox,
                                          "${doc['details']}".text.color(fontGrey).size(12).make(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  12.heightBox,
                  ourButton(
                    title: addNewAddress,
                    color: primaryColor,
                    textColor: whiteColor,
                    onPress: () => Get.to(() => const AddAddressScreen()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

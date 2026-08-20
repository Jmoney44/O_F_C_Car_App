import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/controllers/cart_controller.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/cart_screen/shipping_address_list_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: whiteColor,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ourButton(
            color: primaryColor,
            onPress: () {
              Get.to(() => const ShippingAddressListScreen());
            },
            textColor: whiteColor,
            title: "Proceed to shipping",
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: "Shopping cart".text.color(darkFontGrey).fontFamily(bold).make(),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getCart(currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: "Cart is empty".text.color(fontGrey).make(),
            );
          } else {
            var data = snapshot.data!.docs;
            controller.calculate(data);
            controller.productSnapshot = data;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => 10.heightBox,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "${data[index]['img']}",
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              12.widthBox,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    "${data[index]['title']} (x${data[index]['qty']})"
                                        .text
                                        .fontFamily(semibold)
                                        .size(14)
                                        .color(darkFontGrey)
                                        .make(),
                                    6.heightBox,
                                    "${data[index]['tprice']}"
                                        .numCurrency
                                        .text
                                        .color(darkFontGrey)
                                        .fontFamily(bold)
                                        .make(),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.delete_outline_rounded,
                                color: dangerColor,
                              ).onTap(() {
                                FirestoreServices.deleteDocument(data[index].id);
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  12.heightBox,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      "Total price"
                        .text
                        .fontFamily(semibold)
                        .color(darkFontGrey)
                        .make(),
                      Obx(
                        () => "${controller.totalP.value}"
                          .numCurrency
                          .text
                          .fontFamily(bold)
                          .size(16)
                          .color(darkFontGrey)
                          .make(),
                      ),
                    ],
                  )
                      .box
                      .padding(const EdgeInsets.all(16))
                      .color(lightGrey)
                      .width(double.infinity)
                      .withRounded(value: 16)
                      .make(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

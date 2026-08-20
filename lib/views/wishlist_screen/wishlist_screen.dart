import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/category_screen/item_details.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title:
            "My Wishlist".text.color(darkFontGrey).fontFamily(bold).make(),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getWishlists(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return "No Wishlist yet!".text.color(fontGrey).makeCentered();
          } else {
            var data = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 240),
                itemBuilder: (BuildContext context, int index) {
                  final doc = data[index];
                  return ProductCard(
                    imageUrl: doc['p_imgs'][0],
                    title: "${doc['p_name']}",
                    price: "${doc['p_price']}".numCurrency,
                    isFavorite: true,
                    onFavoriteToggle: () {
                      FirestoreServices.toggleWishlist(doc.id, true);
                    },
                    onTap: () {
                      Get.to(() => ItemDetails(
                            title: "${doc['p_name']}",
                            data: doc,
                          ));
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

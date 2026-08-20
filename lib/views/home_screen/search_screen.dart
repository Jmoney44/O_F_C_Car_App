import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/category_screen/item_details.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/product_card.dart';

class SearchScreen extends StatelessWidget {
  final String? title;
  const SearchScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: title!.text.color(darkFontGrey).fontFamily(semibold).make(),
      ),
      body: FutureBuilder(
        future: FirestoreServices.searchProducts(title),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return "No products found".text.color(fontGrey).makeCentered();
          } else {
            var data = snapshot.data!.docs;
            var filtered = data
                .where(
                  (element) => element['p_name']
                      .toString()
                      .toLowerCase()
                      .contains(title!.toLowerCase()),
                )
                .toList();

            if (filtered.isEmpty) {
              return "No products found".text.color(fontGrey).makeCentered();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 240),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final doc = filtered[index];
                  return ProductCard(
                    imageUrl: doc['p_imgs'][0],
                    title: "${doc['p_name']}",
                    price: "${doc['p_price']}".numCurrency,
                    isFavorite: FirestoreServices.isInWishlist(doc),
                    onFavoriteToggle: () {
                      FirestoreServices.toggleWishlist(
                          doc.id, FirestoreServices.isInWishlist(doc));
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

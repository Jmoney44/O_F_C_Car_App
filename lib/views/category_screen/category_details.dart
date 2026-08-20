import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/product_controller.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/category_screen/item_details.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/pill_chip.dart';
import 'package:ofcluxury_app/views/widgets_common/product_card.dart';

class CategoryDetails extends StatefulWidget {
  final String? title;
  const CategoryDetails({super.key, required this.title});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  @override
  void initState() {
    super.initState();
    selectedTitle = widget.title;
    switchCategory(widget.title);
  }

  switchCategory(title) {
    if (controller.subcat.contains(title)) {
      productMethod = FirestoreServices.getSubCategoryProducts(title);
    } else {
      productMethod = FirestoreServices.getProducts(title);
    }
  }

  var controller = Get.find<ProductController>();

  dynamic productMethod;
  String? selectedTitle;

  @override
  Widget build(BuildContext context) {
    return bgWidget(
        child: Scaffold(
      appBar: AppBar(
        title: widget.title!.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.subcat.isNotEmpty)
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(
                    controller.subcat.length,
                    (index) => pillChip(
                      label: "${controller.subcat[index]}",
                      selected: selectedTitle == "${controller.subcat[index]}",
                      onTap: () {
                        selectedTitle = "${controller.subcat[index]}";
                        switchCategory(selectedTitle);
                        setState(() {});
                      },
                    ),
                  )),
                ),
              ),
            16.heightBox,
            Expanded(
              child: StreamBuilder(
                stream: productMethod,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: loadingIndicator(),
                    );
                  } else if (snapshot.data!.docs.isEmpty) {
                    return "No Products Found!"
                        .text
                        .color(fontGrey)
                        .makeCentered();
                  } else {
                    var data = snapshot.data!.docs;

                    return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: data.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 240,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12),
                        itemBuilder: (context, index) {
                          final doc = data[index];
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
                              controller.checkIfFav(doc);
                              Get.to(
                                () => ItemDetails(
                                  title: "${doc['p_name']}",
                                  data: doc,
                                ),
                              );
                            },
                          );
                        });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/home_controller.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/cart_screen/cart_screen.dart';
import 'package:ofcluxury_app/views/category_screen/category_screen.dart';
import 'package:ofcluxury_app/views/category_screen/item_details.dart';
import 'package:ofcluxury_app/views/home_screen/components/featured_button.dart';
import 'package:ofcluxury_app/views/home_screen/notification_screen.dart';
import 'package:ofcluxury_app/views/home_screen/search_screen.dart';
import 'package:ofcluxury_app/views/wishlist_screen/wishlist_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/home_buttons.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/product_card.dart';
import 'package:ofcluxury_app/views/widgets_common/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<HomeController>();
    return Container(
      color: whiteColor,
      width: context.screenWidth,
      height: context.screenHeight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              10.heightBox,
              //greeting row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: fontGrey),
                  ),
                  12.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Good day 👋".text.color(fontGrey).size(13).make(),
                        (controller.username.isEmpty ? appname : controller.username)
                            .text
                            .fontFamily(bold)
                            .size(16)
                            .color(darkFontGrey)
                            .make(),
                      ],
                    ),
                  ),
                  Icon(Icons.notifications_none_rounded, color: darkFontGrey).onTap(() {
                    Get.to(() => const NotificationScreen());
                  }),
                  16.widthBox,
                  Icon(Icons.favorite_border, color: darkFontGrey).onTap(() {
                    Get.to(() => const WishlistScreen());
                  }),
                  16.widthBox,
                  Icon(Icons.shopping_cart_outlined, color: darkFontGrey).onTap(() {
                    Get.to(() => const CartScreen());
                  }),
                ],
              ),
              16.heightBox,
              //search bar
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextFormField(
                  controller: controller.searchController,
                  style: TextStyle(fontFamily: regular, color: darkFontGrey),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: fontGrey),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune_rounded, color: whiteColor, size: 18),
                      ),
                    ).onTap(() {
                      if (controller.searchController.text.isNotEmptyAndNotNull) {
                        Get.to(() => SearchScreen(
                              title: controller.searchController.text,
                            ));
                      }
                    }),
                    hintText: searchanything,
                    hintStyle: TextStyle(fontFamily: regular, color: fontGrey),
                  ),
                ),
              ),
              14.heightBox,
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //promo swiper
                      VxSwiper.builder(
                          aspectRatio: 16 / 9,
                          autoPlay: true,
                          height: 150,
                          enlargeCenterPage: true,
                          itemCount: slidersList.length,
                          itemBuilder: (context, index) {
                            return Image.asset(
                              slidersList[index],
                              fit: BoxFit.cover,
                            )
                                .box
                                .withRounded(value: 20)
                                .color(lightGrey)
                                .clip(Clip.antiAlias)
                                .margin(const EdgeInsets.symmetric(horizontal: 8))
                                .make();
                          }),

                      20.heightBox,
                      //deals tiles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                            2,
                            (index) => homeButtons(
                                  height: context.screenHeight * 0.13,
                                  width: context.screenWidth / 2.5,
                                  icon: index == 0 ? icTodaysDeal : icFlashDeal,
                                  title: index == 0 ? todayDeal : flashsale,
                                )),
                      ),

                      20.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                            3,
                            (index) => homeButtons(
                                  height: context.screenHeight * 0.13,
                                  width: context.screenWidth / 3.5,
                                  icon: index == 0
                                      ? icTopCategories
                                      : index == 1
                                          ? icBrands
                                          : icTopSeller,
                                  title: index == 0
                                      ? topCategories
                                      : index == 1
                                          ? brand
                                          : topSellers,
                                  onPress: index == 0
                                      ? () => Get.to(() => const CategoryScreen())
                                      : null,
                                )),
                      ),

                      24.heightBox,
                      sectionHeader(title: featuredCategories),
                      16.heightBox,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            3,
                            (index) => Column(
                              children: [
                                featuredButton(
                                    icon: featuredImages1[index],
                                    title: featuredTitles1[index]),
                                10.heightBox,
                                featuredButton(
                                    icon: featuredImages2[index],
                                    title: featuredTitles2[index]),
                              ],
                            ),
                          ).toList(),
                        ),
                      ),

                      24.heightBox,
                      sectionHeader(title: featuredProduct),
                      16.heightBox,
                      SizedBox(
                        height: 210,
                        child: FutureBuilder(
                            future: FirestoreServices.getFeaturedProducts(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: loadingIndicator(),
                                );
                              } else if (snapshot.data!.docs.isEmpty) {
                                return "No featured products"
                                    .text
                                    .color(fontGrey)
                                    .makeCentered();
                              } else {
                                var featuredData = snapshot.data!.docs;

                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredData.length,
                                  separatorBuilder: (_, __) => 12.widthBox,
                                  itemBuilder: (context, index) {
                                    final doc = featuredData[index];
                                    return SizedBox(
                                      width: 160,
                                      child: ProductCard(
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
                                      ),
                                    );
                                  },
                                );
                              }
                            }),
                      ),

                      24.heightBox,
                      sectionHeader(title: allproducts),
                      16.heightBox,
                      StreamBuilder(
                        stream: FirestoreServices.allproducts(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return loadingIndicator();
                          } else {
                            var allproductsdata = snapshot.data!.docs;
                            return GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: allproductsdata.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        mainAxisExtent: 240),
                                itemBuilder: (context, index) {
                                  final doc = allproductsdata[index];
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
                                });
                          }
                        },
                      ),
                      20.heightBox,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

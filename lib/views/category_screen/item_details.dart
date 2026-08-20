import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/product_controller.dart';
import 'package:ofcluxury_app/views/chat_screen/chat_screen.dart';
import 'package:ofcluxury_app/views/category_screen/make_offer_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';
import 'package:ofcluxury_app/views/widgets_common/product_card.dart';

class ItemDetails extends StatelessWidget {
  final String? title;
  final dynamic data;
  const ItemDetails({super.key, required this.title, this.data});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProductController());
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        controller.resetValues();
        return true;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              controller.resetValues();
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: title!.text.color(darkFontGrey).fontFamily(bold).make(),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
            Obx(
              () => IconButton(
                  onPressed: () {
                    if (controller.isFav.value) {
                      controller.removeFromWishlist(data.id, context);
                    } else {
                      controller.addToWishlist(data.id, context);
                    }
                  },
                  icon: Icon(
                    controller.isFav.value
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline,
                    color: controller.isFav.value ? dangerColor : darkFontGrey,
                  )),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //swiper section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: VxSwiper.builder(
                          autoPlay: true,
                          height: 280,
                          itemCount: data['p_imgs'].length,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1.0,
                          itemBuilder: (context, index) {
                            return Image.network(
                              data["p_imgs"][index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          }),
                    ),

                    16.heightBox,
                    //title and details section
                    title!.text
                        .size(19)
                        .color(darkFontGrey)
                        .fontFamily(bold)
                        .make(),
                    8.heightBox,
                    //rating
                    Row(
                      children: [
                        VxRating(
                            isSelectable: false,
                            value: double.parse(data['p_rating']),
                            onRatingUpdate: (value) {},
                            normalColor: textfieldGrey,
                            selectionColor: golden,
                            count: 5,
                            maxRating: 5,
                            size: 20,
                            stepInt: true),
                      ],
                    ),

                    12.heightBox,

                    "${data['p_price']}"
                        .numCurrency
                        .text
                        .color(darkFontGrey)
                        .fontFamily(extraBold)
                        .size(22)
                        .make(),

                    16.heightBox,

                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: whiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront_rounded, color: darkFontGrey),
                        ),
                        12.widthBox,
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                "${data['p_seller']}"
                                    .text
                                    .fontFamily(semibold)
                                    .color(darkFontGrey)
                                    .make(),
                                4.widthBox,
                                const Icon(Icons.verified_rounded, color: accentBlue, size: 16),
                              ],
                            ),
                            "Seller".text.color(fontGrey).size(12).make(),
                          ],
                        )),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: whiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded, color: darkFontGrey, size: 20),
                        ).onTap(() {
                          Get.to(
                            () => const ChatScreen(),
                            arguments: [data['p_seller'], data['vendor_id']],
                          );
                        })
                      ],
                    )
                        .box
                        .height(70)
                        .padding(const EdgeInsets.symmetric(horizontal: 12))
                        .color(lightGrey)
                        .withRounded(value: 16)
                        .make(),

                    //color section
                    16.heightBox,
                    Obx(
                      () => Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child:
                                    "Color".text.color(fontGrey).size(13).make(),
                              ),
                              Row(
                                children: List.generate(
                                  data['p_colors'].length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: index == controller.colorIndex.value
                                            ? darkFontGrey
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        VxBox()
                                            .size(34, 34)
                                            .roundedFull
                                            .color(Color(data['p_colors'][index]))
                                            .make()
                                            .onTap(() {
                                          controller.changeColorIndex(index);
                                        }),
                                        Visibility(
                                          visible: index ==
                                              controller.colorIndex.value,
                                          child: const Icon(Icons.done,
                                              color: Colors.white, size: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          12.heightBox,

                          //quantity row
                          Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: "Quantity"
                                    .text
                                    .color(fontGrey)
                                    .size(13)
                                    .make(),
                              ),
                              Obx(
                                () => Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          controller.decreaseQuantity();
                                          controller.calculateTotalPrice(
                                              int.parse(data['p_price']));
                                        },
                                        icon: const Icon(Icons.remove_circle_outline, color: darkFontGrey)),
                                    controller.quantity.value.text
                                        .size(16)
                                        .color(darkFontGrey)
                                        .fontFamily(bold)
                                        .make(),
                                    IconButton(
                                        onPressed: () {
                                          controller.increaseQuantity(
                                              int.parse(data['p_quantity']));
                                          controller.calculateTotalPrice(
                                              int.parse(data['p_price']));
                                        },
                                        icon: const Icon(Icons.add_circle_outline, color: darkFontGrey)),
                                    10.widthBox,
                                    "(${data['p_quantity']} available)"
                                        .text
                                        .color(fontGrey)
                                        .size(12)
                                        .make(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          //total row
                          Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child:
                                    "Total".text.color(fontGrey).size(13).make(),
                              ),
                              "${controller.totalPrice.value}"
                                  .numCurrency
                                  .text
                                  .color(darkFontGrey)
                                  .size(16)
                                  .fontFamily(bold)
                                  .make(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //description section
                    20.heightBox,

                    "Description"
                        .text
                        .color(darkFontGrey)
                        .fontFamily(bold)
                        .size(16)
                        .make(),
                    8.heightBox,
                    "${data['p_desc']}".text.color(fontGrey).make(),

                    //buttons section
                    12.heightBox,

                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: List.generate(
                        itemDetailsButtonsList.length,
                        (index) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: itemDetailsButtonsList[index]
                              .text
                              .fontFamily(semibold)
                              .color(darkFontGrey)
                              .make(),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: fontGrey),
                        ),
                      ),
                    ),
                    12.heightBox,
                    //products may like section

                    productsyoumaylike.text
                        .fontFamily(bold)
                        .size(16)
                        .color(darkFontGrey)
                        .make(),
                    12.heightBox,
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, __) => 12.widthBox,
                        itemBuilder: (context, index) => SizedBox(
                          width: 150,
                          child: const ProductCard(
                            imageUrl: imgP1,
                            isNetworkImage: false,
                            title: "Laptop 4GB/64GB",
                            price: "\$600",
                          ),
                        ),
                      ),
                    ),
                    12.heightBox,
                  ],
                ),
              ),
            )),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ourButton(
                          outlined: true,
                          color: darkFontGrey,
                          onPress: () {
                            if (controller.quantity.value > 0) {
                              controller.addToCart(
                                  color: data['p_colors'][controller.colorIndex.value],
                                  context: context,
                                  vendorID: data['vendor_id'],
                                  productId: data.id,
                                  img: data['p_imgs'][0],
                                  qty: controller.quantity.value,
                                  sellername: data['p_seller'],
                                  title: data['p_name'],
                                  tprice: controller.totalPrice.value);
                              VxToast.show(context, msg: "Added to cart");
                            } else {
                              VxToast.show(context,
                                  msg: "Minimum 1 product is required");
                            }
                          },
                          title: "Add to cart"),
                    ),
                    12.widthBox,
                    Expanded(
                      child: ourButton(
                          color: primaryColor,
                          textColor: whiteColor,
                          onPress: () {
                            Get.to(() => MakeOfferScreen(data: data));
                          },
                          title: makeAnOffer),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

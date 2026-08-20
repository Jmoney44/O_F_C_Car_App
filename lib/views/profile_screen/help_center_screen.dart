import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/chat_screen/chat_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/pill_chip.dart';

const _faqCategories = ["General", "Account", "Service", "Payment"];
const _faqItems = [
  ["What is $appname?", "$appname is a marketplace app for buying and selling top brands, all in one place."],
  ["How to use $appname?", "Browse categories or search for a product, add it to your cart or make an offer, then checkout."],
  ["How do I cancel an order?", "Open My Orders, select the order, and contact the seller through chat to arrange a cancellation."],
  ["Can I get a discount at checkout?", "Keep an eye on the Special Offers section on Home for current promotions."],
  ["Why can't I make a payment?", "Make sure your selected payment method (e.g. wallet balance) can cover the order total."],
];

const _contactRows = [
  [Icons.headset_mic_outlined, customerService],
  [Icons.chat_bubble_outline_rounded, "WhatsApp"],
  [Icons.language_outlined, "Website"],
  [Icons.facebook_outlined, "Facebook"],
  [Icons.alternate_email_rounded, "Twitter"],
  [Icons.camera_alt_outlined, "Instagram"],
];

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int selectedCategory = 0;
  String search = "";

  @override
  Widget build(BuildContext context) {
    final filteredFaq = _faqItems
        .where((item) => item[0].toLowerCase().contains(search.toLowerCase()))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: helpCenter.text.fontFamily(bold).color(darkFontGrey).make(),
          bottom: TabBar(
            labelColor: darkFontGrey,
            unselectedLabelColor: fontGrey,
            labelStyle: TextStyle(fontFamily: semibold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontFamily: regular, fontSize: 14),
            indicatorColor: primaryColor,
            tabs: [Tab(text: faq), Tab(text: contactUs)],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _faqCategories.length,
                      itemBuilder: (context, index) => pillChip(
                        label: _faqCategories[index],
                        selected: selectedCategory == index,
                        onTap: () => setState(() => selectedCategory = index),
                      ),
                    ),
                  ),
                  16.heightBox,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => search = value),
                      style: TextStyle(fontFamily: regular, color: darkFontGrey),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: fontGrey),
                        hintText: "Search",
                        hintStyle: TextStyle(fontFamily: regular, color: fontGrey),
                      ),
                    ),
                  ),
                  16.heightBox,
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredFaq.length,
                      separatorBuilder: (_, __) => 10.heightBox,
                      itemBuilder: (context, index) => ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                        collapsedBackgroundColor: lightGrey,
                        backgroundColor: lightGrey,
                        collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: filteredFaq[index][0]
                            .text
                            .fontFamily(semibold)
                            .color(darkFontGrey)
                            .make(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: filteredFaq[index][1].text.color(fontGrey).make(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _contactRows.length,
              separatorBuilder: (_, __) => 10.heightBox,
              itemBuilder: (context, index) {
                final icon = _contactRows[index][0] as IconData;
                final label = _contactRows[index][1] as String;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: darkFontGrey),
                      14.widthBox,
                      Expanded(child: label.text.fontFamily(semibold).color(darkFontGrey).make()),
                    ],
                  ),
                ).onTap(() {
                  if (label == customerService) {
                    Get.to(
                      () => const ChatScreen(),
                      arguments: [customerService, "customer_service_bot"],
                    );
                  } else {
                    VxToast.show(context, msg: "$label link not available in this demo");
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

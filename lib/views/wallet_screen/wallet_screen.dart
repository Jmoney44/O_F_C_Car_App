import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/home_controller.dart';
import 'package:ofcluxury_app/controllers/wallet_controller.dart';
import 'package:ofcluxury_app/views/wallet_screen/top_up_screen.dart';
import 'package:ofcluxury_app/views/wallet_screen/transaction_history_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: myEWallet.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (homeController.username.isEmpty ? appname : homeController.username)
                          .text
                          .color(whiteColor)
                          .fontFamily(semibold)
                          .make(),
                      const Icon(Icons.contactless_outlined, color: whiteColor),
                    ],
                  ),
                  28.heightBox,
                  yourBalance.text.color(whiteColor.withValues(alpha: 0.7)).size(13).make(),
                  6.heightBox,
                  StreamBuilder<num>(
                    stream: controller.balanceStream(),
                    builder: (context, snapshot) {
                      final balance = snapshot.data ?? 0;
                      return "$balance".numCurrency.text
                          .color(whiteColor)
                          .fontFamily(extraBold)
                          .size(26)
                          .make();
                    },
                  ),
                  16.heightBox,
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => const TopUpScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: whiteColor,
                        foregroundColor: darkFontGrey,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: topUp.text.fontFamily(semibold).make(),
                    ),
                  ),
                ],
              ),
            ),
            24.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                transactionHistory.text.fontFamily(bold).size(16).color(darkFontGrey).make(),
                seeAll.text.color(fontGrey).size(13).make().onTap(() {
                  Get.to(() => const TransactionHistoryScreen());
                }),
              ],
            ),
            16.heightBox,
            StreamBuilder<QuerySnapshot>(
              stream: controller.transactionsStream(limit: 5),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: loadingIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return "No transactions yet".text.color(fontGrey).makeCentered();
                }
                return Column(
                  children: docs.map((doc) {
                    final isIn = doc['direction'] == 'in';
                    final date = doc['created_on'] != null
                        ? intl.DateFormat("MMM d, yyyy").format(doc['created_on'].toDate())
                        : "";
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: lightGrey,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: darkFontGrey,
                              size: 18,
                            ),
                          ),
                          12.widthBox,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "${doc['title']}".text.fontFamily(semibold).color(darkFontGrey).make(),
                                4.heightBox,
                                date.text.color(fontGrey).size(12).make(),
                              ],
                            ),
                          ),
                          "${doc['amount']}".numCurrency.text
                              .fontFamily(semibold)
                              .color(isIn ? darkFontGrey : dangerColor)
                              .make(),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

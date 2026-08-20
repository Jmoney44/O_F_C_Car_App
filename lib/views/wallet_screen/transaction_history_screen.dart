import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/wallet_controller.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: transactionHistory.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.transactionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return "No transactions yet".text.color(fontGrey).makeCentered();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => 14.heightBox,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final isIn = doc['direction'] == 'in';
              final date = doc['created_on'] != null
                  ? intl.DateFormat("MMM d, yyyy | h:mm a").format(doc['created_on'].toDate())
                  : "";
              return Row(
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
              );
            },
          );
        },
      ),
    );
  }
}

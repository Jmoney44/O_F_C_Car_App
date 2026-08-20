import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/orders_screen/leave_review_screen.dart';
import 'package:ofcluxury_app/views/orders_screen/orders_details.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: orders.text.color(darkFontGrey).fontFamily(bold).make(),
          bottom: TabBar(
            labelColor: darkFontGrey,
            unselectedLabelColor: fontGrey,
            labelStyle: TextStyle(fontFamily: semibold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontFamily: regular, fontSize: 14),
            indicatorColor: primaryColor,
            tabs: [Tab(text: active), Tab(text: completed)],
          ),
        ),
        body: StreamBuilder(
          stream: FirestoreServices.getAllOrders(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: loadingIndicator());
            }
            final allOrders = snapshot.data!.docs;
            final activeOrders =
                allOrders.where((doc) => doc['order_delivered'] != true).toList();
            final completedOrders =
                allOrders.where((doc) => doc['order_delivered'] == true).toList();

            return TabBarView(
              children: [
                _OrdersList(orders: activeOrders, isCompletedTab: false),
                _OrdersList(orders: completedOrders, isCompletedTab: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<QueryDocumentSnapshot> orders;
  final bool isCompletedTab;
  const _OrdersList({required this.orders, required this.isCompletedTab});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: textfieldGrey),
              16.heightBox,
              noOrderYet.text.fontFamily(bold).color(darkFontGrey).make(),
              8.heightBox,
              noOrderYetBody.text.center.color(fontGrey).make(),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => 10.heightBox,
      itemBuilder: (BuildContext context, int index) {
        final data = orders[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Get.to(() => OrderDetails(data: data));
            },
            leading: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: whiteColor,
                shape: BoxShape.circle,
              ),
              child: "${index + 1}".text.fontFamily(bold).color(darkFontGrey).makeCentered(),
            ),
            title: data['order_code']
                .toString()
                .text
                .color(darkFontGrey)
                .fontFamily(semibold)
                .make(),
            subtitle: data['total_amount']
                .toString()
                .numCurrency
                .text
                .color(fontGrey)
                .fontFamily(bold)
                .size(13)
                .make(),
            trailing: isCompletedTab
                ? SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {
                        final firstItem =
                            (data['orders'] as List).isNotEmpty ? data['orders'][0] : null;
                        Get.to(() => LeaveReviewScreen(
                              productId: firstItem?['product_id'],
                              productTitle: firstItem?['title'] ?? "your order",
                              productImg: firstItem?['img'],
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: const StadiumBorder(),
                      ),
                      child: leaveReview.text.color(whiteColor).size(12).make(),
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: fontGrey),
          ),
        );
      },
    );
  }
}

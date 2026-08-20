import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/orders_screen/components/order_place_deatils.dart';
import 'package:ofcluxury_app/views/orders_screen/components/order_status.dart';
import 'package:ofcluxury_app/views/wallet_screen/e_receipt_screen.dart';
import 'package:intl/intl.dart' as intl;

class OrderDetails extends StatelessWidget {
  final dynamic data;
  const OrderDetails({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "Order Details"
            .text
            .fontFamily(bold)
            .color(darkFontGrey)
            .make(),
        actions: [
          TextButton.icon(
            onPressed: () {
              final items = (data['orders'] as List);
              final shippingCost = (data['shipping_cost'] as num?) ?? 0;
              final taxAmount = (data['tax_amount'] as num?) ?? 0;
              final totalAmount = (data['total_amount'] as num?) ?? 0;
              Get.to(() => EReceiptScreen(
                    imageUrl: items.isNotEmpty ? items[0]['img'] : null,
                    itemTitle: items.isNotEmpty ? "${items[0]['title']}" : "Order",
                    itemSubtitle: items.length > 1 ? "+ ${items.length - 1} more item(s)" : null,
                    itemAmount: totalAmount - shippingCost - taxAmount,
                    shippingAmount: shippingCost,
                    taxAmount: taxAmount,
                    totalAmount: totalAmount,
                    paymentMethodLabel: "${data['payment_method']}",
                    date: data['order_date'] != null
                        ? intl.DateFormat("MMM d, yyyy | h:mm a").format(data['order_date'].toDate())
                        : "",
                    transactionId: "${data['order_code']}",
                  ));
            },
            icon: const Icon(Icons.receipt_long_outlined, size: 18, color: darkFontGrey),
            label: eReceipt.text.color(darkFontGrey).size(13).make(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              12.heightBox,
              Container(
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    orderStatus(
                        icon: Icons.done,
                        title: "Placed",
                        showDone: data['order_placed']),
                    orderStatus(
                        icon: Icons.thumb_up_outlined,
                        title: "Confirmed",
                        showDone: data['order_confirmed']),
                    orderStatus(
                        icon: Icons.local_shipping_outlined,
                        title: "On Delivery",
                        showDone: data['order_on_delivery']),
                    orderStatus(
                        icon: Icons.done_all_rounded,
                        title: "Delivered",
                        showDone: data['order_delivered']),
                  ],
                ).box.padding(const EdgeInsets.symmetric(horizontal: 8, vertical: 4)).make(),
              ),
              16.heightBox,
              Column(
                children: [
                  orderPlaceDetails(
                    d1: data['order_code'],
                    d2: data['shipping_method'],
                    title1: "Order Code",
                    title2: "Shipping Method",
                  ),
                  orderPlaceDetails(
                    d1: intl.DateFormat()
                        .add_yMd()
                        .format((data['order_date'].toDate())),
                    d2: data['payment_method'],
                    title1: "Order Date",
                    title2: "Payment Method",
                  ),
                  orderPlaceDetails(
                    d1: data['order_confirmed'] == true ? "Paid" : "Unpaid",
                    d2: data['order_delivered'] == true
                        ? "Delivered"
                        : data['order_on_delivery'] == true
                            ? "On Delivery"
                            : "Order Placed",
                    title1: "Payment Status",
                    title2: "Delivery Status",
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "Shipping Address".text.fontFamily(semibold).color(darkFontGrey).make(),
                              4.heightBox,
                              "${data['order_by_name']}".text.color(fontGrey).make(),
                              "${data['order_by_email']}".text.color(fontGrey).make(),
                              "${data['order_by_address']}".text.color(fontGrey).make(),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              "Total Amount".text.fontFamily(semibold).color(darkFontGrey).make(),
                              4.heightBox,
                              "${data['total_amount']}"
                                  .text
                                  .color(darkFontGrey)
                                  .fontFamily(bold)
                                  .make(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).box.color(lightGrey).withRounded(value: 16).make(),
              20.heightBox,
              "Ordered Product"
                  .text
                  .size(16)
                  .color(darkFontGrey)
                  .fontFamily(bold)
                  .make(),
              12.heightBox,
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: List.generate(data['orders'].length, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      orderPlaceDetails(
                          title1: data['orders'][index]['title'],
                          title2: data['orders'][index]['tprice'],
                          d1: "${data['orders'][index]['qty']}x",
                          d2: "Refundable"),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(data['orders'][index]['color']),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      12.heightBox,
                    ],
                  );
                }).toList(),
              )
                  .box
                  .color(lightGrey)
                  .withRounded(value: 16)
                  .margin(const EdgeInsets.only(bottom: 4))
                  .make(),
              20.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

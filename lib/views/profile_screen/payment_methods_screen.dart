import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/profile_screen/add_card_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';

// PayPal/Google Pay/Apple Pay stay label-only "Connected" rows, same
// trust level as the rest of this demo checkout — only saved cards
// (below) are backed by a real Firestore write.
const _staticMethods = [
  [Icons.paypal, "PayPal"],
  [Icons.g_mobiledata_rounded, "Google Pay"],
  [Icons.apple, "Apple Pay"],
];

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: paymentLabel.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ..._staticMethods.map((m) => _row(
                          icon: m[0] as IconData,
                          label: m[1] as String,
                          trailing: connected,
                        )),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirestoreServices.getCards(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: loadingIndicator());
                        }
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            return _row(
                              icon: Icons.credit_card_rounded,
                              label: "${doc['brand']} •••• ${doc['last4']}",
                              trailing: connected,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ourButton(
                title: addNewCard,
                color: primaryColor,
                textColor: whiteColor,
                onPress: () => Get.to(() => const AddCardScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({required IconData icon, required String label, required String trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          trailing.text.color(fontGrey).size(13).make(),
        ],
      ),
    );
  }
}

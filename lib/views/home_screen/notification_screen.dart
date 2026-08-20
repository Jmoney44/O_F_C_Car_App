import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

class _NotificationItem {
  final IconData icon;
  final String title;
  final String body;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
  });
}

// Static placeholder content — there is no live notifications backend
// yet, so this mirrors the design reference rather than pretending to
// be real-time data.
const _todayItems = [
  _NotificationItem(
    icon: Icons.local_offer_outlined,
    title: "New deals available!",
    body: "Check out this week's special offers on top brands.",
  ),
];

const _yesterdayItems = [
  _NotificationItem(
    icon: Icons.local_shipping_outlined,
    title: "New services available!",
    body: "You can now track your orders in real time.",
  ),
  _NotificationItem(
    icon: Icons.credit_card_outlined,
    title: "Payment method connected!",
    body: "Your card has been linked successfully.",
  ),
];

const _earlierItems = [
  _NotificationItem(
    icon: Icons.check_circle_outline,
    title: "Account setup successful!",
    body: "Your account is fully set up and ready to go.",
  ),
];

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: notification.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _section("Today", _todayItems),
          _section("Yesterday", _yesterdayItems),
          _section("Earlier", _earlierItems),
        ],
      ),
    );
  }

  Widget _section(String label, List<_NotificationItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        12.heightBox,
        label.text.fontFamily(semibold).color(darkFontGrey).size(15).make(),
        12.heightBox,
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: whiteColor, size: 20),
                  ),
                  12.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        item.title.text.fontFamily(semibold).color(darkFontGrey).make(),
                        4.heightBox,
                        item.body.text.color(fontGrey).size(13).make(),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

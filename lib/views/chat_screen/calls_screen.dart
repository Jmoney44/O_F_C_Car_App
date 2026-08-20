import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/chat_screen/call_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';

const _callStatuses = [incoming, outgoing, missed];
const _callStatusIcons = [
  Icons.call_received_rounded,
  Icons.call_made_rounded,
  Icons.call_missed_rounded,
];

/// The "Calls" tab body on the Inbox screen. There's no real telephony —
/// this reuses the real chat contact list (so names aren't fabricated)
/// but the call direction/duration shown per row is decorative UI only.
Widget callsListBody() {
  return StreamBuilder(
    stream: FirestoreServices.getAllMessages(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) {
        return Center(child: loadingIndicator());
      } else if (snapshot.data!.docs.isEmpty) {
        return noCallsYet.text.color(fontGrey).makeCentered();
      }
      final data = snapshot.data!.docs;
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        separatorBuilder: (_, __) => 14.heightBox,
        itemBuilder: (context, index) {
          final name = "${data[index]['friend_name']}";
          final statusIndex = index % _callStatuses.length;
          final date = data[index]['created_on'] != null
              ? intl.DateFormat.yMMMd().format(data[index]['created_on'].toDate())
              : "";
          return Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: lightGrey,
                child: Icon(Icons.storefront_rounded, color: fontGrey),
              ),
              12.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name.text.fontFamily(semibold).color(darkFontGrey).make(),
                    4.heightBox,
                    Row(
                      children: [
                        Icon(_callStatusIcons[statusIndex],
                            size: 14,
                            color: statusIndex == 2 ? dangerColor : fontGrey),
                        4.widthBox,
                        "${_callStatuses[statusIndex]} | $date"
                            .text
                            .color(fontGrey)
                            .size(12)
                            .make(),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.call_outlined, color: darkFontGrey).onTap(() {
                Get.to(() => CallScreen(name: name));
              }),
            ],
          );
        },
      );
    },
  );
}

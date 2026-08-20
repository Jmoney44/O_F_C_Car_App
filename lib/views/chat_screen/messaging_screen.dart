import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/chat_screen/chat_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';

/// The "Chats" tab body on the Inbox screen — extracted from a standalone
/// screen so it can be embedded in a `TabBarView` alongside Calls.
Widget chatsListBody() {
  return StreamBuilder(
    stream: FirestoreServices.getAllMessages(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: loadingIndicator(),
        );
      } else if (snapshot.data!.docs.isEmpty) {
        return "No messages yet!".text.color(fontGrey).makeCentered();
      } else {
        var data = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          separatorBuilder: (_, __) => 10.heightBox,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Get.to(
                    () => const ChatScreen(),
                    arguments: [
                      data[index]['friend_name'],
                      data[index]['toId'],
                    ],
                  );
                },
                leading: const CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.person,
                    color: whiteColor,
                  ),
                ),
                title: "${data[index]['friend_name']}".text.fontFamily(semibold).color(darkFontGrey).make(),
                subtitle: "${data[index]['last_msg']}".text.color(fontGrey).make(),
              ),
            );
          },
        );
      }
    },
  );
}

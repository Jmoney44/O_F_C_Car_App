import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/controllers/chats_controller.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/chat_screen/components/sender_bubble.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ChatsController());

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: "${controller.friendName}".text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Obx(
                ()=> controller.isLoading.value
                ? Center(
                    child: loadingIndicator(),
                  )
                  : Expanded(
                    child: StreamBuilder(
                      stream: FirestoreServices.getChatMessages(controller.chatDocId.toString()),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: loadingIndicator(),
                          );
                        } else if (snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: "Send a message...".text.color(fontGrey).make(),
                          );
                        } else {
                          return ListView(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            children: snapshot.data!.docs.mapIndexed((currentValue, index) {
                              var data = snapshot.data!.docs[index];

                              return Align(
                                alignment:
                                  data['uid'] == currentUser!.uid ? Alignment.centerRight : Alignment.centerLeft,
                                child: senderBubble(data));
                            }).toList(),
                          );
                        }
                      },
                    ),
                ),
              ),
              10.heightBox,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.msgController,
                        style: TextStyle(fontFamily: regular, color: darkFontGrey),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message...",
                          hintStyle: TextStyle(fontFamily: regular, color: fontGrey),
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          controller.sendMsg(controller.msgController.text);
                          controller.msgController.clear();
                        },
                        icon: const Icon(Icons.arrow_upward_rounded, color: whiteColor, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              12.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}

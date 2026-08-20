import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/chat_screen/calls_screen.dart';
import 'package:ofcluxury_app/views/chat_screen/messaging_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: inbox.text.fontFamily(bold).color(darkFontGrey).make(),
          bottom: TabBar(
            labelColor: darkFontGrey,
            unselectedLabelColor: fontGrey,
            labelStyle: TextStyle(fontFamily: semibold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontFamily: regular, fontSize: 14),
            indicatorColor: primaryColor,
            tabs: [Tab(text: chats), Tab(text: calls)],
          ),
        ),
        body: TabBarView(
          children: [chatsListBody(), callsListBody()],
        ),
      ),
    );
  }
}

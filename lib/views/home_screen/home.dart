import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/controllers/home_controller.dart';
import 'package:ofcluxury_app/views/home_screen/home_screen.dart';
import 'package:ofcluxury_app/views/home_screen/inbox_screen.dart';
import 'package:ofcluxury_app/views/orders_screen/orders_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/profile_screen.dart';
import 'package:ofcluxury_app/views/wallet_screen/wallet_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/exit_dialog.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    //init home controller
    var controller = Get.put(HomeController());

    var navbarItem = const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: home),
      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: orders),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: inbox),
      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: myWallet),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: account),
    ];

    var navBody = const [
      HomeScreen(),
      OrdersScreen(),
      InboxScreen(),
      WalletScreen(),
      ProfileScreen(),
    ];

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => exitDialog(context));
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            Obx(
              () => Expanded(
                  child: navBody.elementAt(controller.currentNavIndex.value)),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: whiteColor,
            border: Border(top: BorderSide(color: textfieldGrey, width: 1)),
          ),
          child: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.currentNavIndex.value,
              selectedItemColor: primaryColor,
              unselectedItemColor: fontGrey,
              selectedLabelStyle: TextStyle(fontFamily: semibold, fontSize: 11),
              unselectedLabelStyle: TextStyle(fontFamily: regular, fontSize: 11),
              type: BottomNavigationBarType.fixed,
              backgroundColor: whiteColor,
              elevation: 0,
              items: navbarItem,
              onTap: (value) {
                controller.currentNavIndex.value = value;
              },
            ),
          ),
        ),
      ),
    );
  }
}

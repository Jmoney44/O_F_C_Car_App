import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/consts/lists.dart';
import 'package:ofcluxury_app/controllers/auth_controller.dart';
import 'package:ofcluxury_app/controllers/profile_controller.dart';
import 'package:ofcluxury_app/services/firestore_services.dart';
import 'package:ofcluxury_app/views/auth_screen/lets_you_in_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/address_book_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/components/details_card.dart';
import 'package:ofcluxury_app/views/profile_screen/edit_profile_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/help_center_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/invite_friends_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/language_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/notification_settings_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/payment_methods_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/privacy_policy_screen.dart';
import 'package:ofcluxury_app/views/profile_screen/security_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/bg_widget.dart';
import 'package:ofcluxury_app/views/widgets_common/loading_indicator.dart';
import 'package:ofcluxury_app/views/wishlist_screen/wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _destinations = <Widget Function()>[
    () => const WishlistScreen(),
    () => const AddressBookScreen(),
    () => const NotificationSettingsScreen(),
    () => const PaymentMethodsScreen(),
    () => const SecurityScreen(),
    () => const LanguageScreen(),
    () => const PrivacyPolicyScreen(),
    () => const HelpCenterScreen(),
    () => const InviteFriendsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProfileController());

    return bgWidget(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirestoreServices.getUser(currentUser!.uid),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
              );
            } else {
              var data = snapshot.data!.docs[0];

              return SafeArea(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    10.heightBox,
                    Row(
                      children: [
                        "Profile".text.fontFamily(bold).size(20).color(darkFontGrey).make(),
                        const Spacer(),
                        Icon(Icons.edit_outlined, color: darkFontGrey).onTap(() {
                          controller.nameController.text = data['name'];
                          Get.to(() => EditProfileScreen(data: data));
                        }),
                      ],
                    ),
                    20.heightBox,

                    //users details section
                    Row(
                      children: [
                        data['imageUrl'] == ''
                            ? Image.asset(imgProfile2,
                                    width: 64, height: 64, fit: BoxFit.cover)
                                .box
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make()
                            : Image.network(data['imageUrl'],
                                    width: 64, height: 64, fit: BoxFit.cover)
                                .box
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make(),
                        14.widthBox,
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "${data['name']}"
                                .text
                                .fontFamily(bold)
                                .size(16)
                                .color(darkFontGrey)
                                .make(),
                            4.heightBox,
                            "${data['email']}".text.color(fontGrey).size(13).make(),
                          ],
                        )),
                      ],
                    ),

                    24.heightBox,

                    FutureBuilder(
                        future: FirestoreServices.getCounts(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: loadingIndicator());
                          } else {
                            var countData = snapshot.data;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                detailsCard(
                                    count: countData[0].toString(),
                                    title: "in your cart",
                                    width: context.screenWidth / 3.6),
                                detailsCard(
                                    count: countData[1].toString(),
                                    title: "in your wishlist",
                                    width: context.screenWidth / 3.6),
                                detailsCard(
                                    count: countData[2].toString(),
                                    title: "your orders",
                                    width: context.screenWidth / 3.6),
                              ],
                            );
                          }
                        }),

                    24.heightBox,

                    //buttons section
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              ...List.generate(profileButtonsList.length, (index) {
                                return ListTile(
                                  onTap: () => Get.to(_destinations[index]),
                                  leading: Icon(profileButtonIcon[index], color: darkFontGrey),
                                  title: profileButtonsList[index]
                                      .text
                                      .fontFamily(semibold)
                                      .color(darkFontGrey)
                                      .make(),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 15, color: fontGrey),
                                );
                              }),
                              Divider(color: textfieldGrey, height: 1),
                              ListTile(
                                onTap: () async {
                                  await Get.put(AuthController())
                                      .signoutMethod(context);
                                  Get.offAll(() => const LetsYouInScreen());
                                },
                                leading: const Icon(Icons.logout_rounded, color: dangerColor),
                                title: "Logout".text.fontFamily(semibold).color(dangerColor).make(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    12.heightBox,
                  ],
                ),
              ));
            }
          },
        ),
      ),
    );
  }
}

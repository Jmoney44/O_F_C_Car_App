import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';

/// Static sample contact list — no contacts/permissions package is
/// present, and no real SMS is sent. Invite/Invited is local UI state.
const _sampleContacts = [
  ["Tynisha Obey", "+1-300-555-0135"],
  ["Florencio Dorrance", "+1-202-555-0136"],
  ["Chantal Shelburne", "+1-300-555-0119"],
  ["Maryland Winkles", "+1-300-555-0161"],
  ["Rodolfo Goode", "+1-300-555-0136"],
  ["Benny Spanbauer", "+1-202-555-0167"],
  ["Tyra Dhillon", "+1-202-555-0119"],
];

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final invitedIndexes = <int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: inviteFriends.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleContacts.length,
        separatorBuilder: (_, __) => 12.heightBox,
        itemBuilder: (context, index) {
          final isInvited = invitedIndexes.contains(index);
          return Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: lightGrey,
                child: Icon(Icons.person, color: fontGrey),
              ),
              12.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sampleContacts[index][0]
                        .text
                        .fontFamily(semibold)
                        .color(darkFontGrey)
                        .make(),
                    4.heightBox,
                    _sampleContacts[index][1].text.color(fontGrey).size(12).make(),
                  ],
                ),
              ),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: isInvited
                      ? null
                      : () => setState(() => invitedIndexes.add(index)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInvited ? whiteColor : primaryColor,
                    disabledBackgroundColor: whiteColor,
                    side: isInvited ? const BorderSide(color: textfieldGrey, width: 1.5) : null,
                    shape: const StadiumBorder(),
                  ),
                  child: (isInvited ? invited : invite)
                      .text
                      .color(isInvited ? darkFontGrey : whiteColor)
                      .size(12)
                      .make(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

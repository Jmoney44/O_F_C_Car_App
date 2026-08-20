import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/pin_service.dart';
import 'package:ofcluxury_app/views/auth_screen/fingerprint_screen.dart';

/// PIN setup step shown once after signup, and reachable again from
/// Profile > Security > Change PIN. The PIN is persisted locally
/// (see PinService) and later checked for real by EnterPinScreen before
/// payments/top-ups — not bank-grade security, but a real local gate.
class CreatePinScreen extends StatefulWidget {
  /// When true (Profile > Security > Change PIN), saving the PIN just
  /// pops back with a confirmation instead of continuing the
  /// post-signup setup wizard into FingerprintScreen.
  final bool standalone;
  const CreatePinScreen({super.key, this.standalone = false});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String pin = "";

  void _addDigit(String digit) {
    if (pin.length < 4) {
      setState(() => pin += digit);
      if (pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () async {
          await PinService.savePin(pin);
          if (!mounted) return;
          if (widget.standalone) {
            VxToast.show(context, msg: "PIN updated");
            Get.back();
          } else {
            Get.to(() => const FingerprintScreen());
          }
        });
      }
    }
  }

  void _removeDigit() {
    if (pin.isNotEmpty) setState(() => pin = pin.substring(0, pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: createNewPin.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            40.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: createPinInstruction.text.center.color(fontGrey).size(14).make(),
            ),
            40.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < pin.length;
                return Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: index == pin.length ? darkFontGrey : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: filled
                      ? const Icon(Icons.circle, size: 12, color: darkFontGrey)
                      : null,
                );
              }),
            ),
            const Spacer(),
            _NumberPad(onDigit: _addDigit, onBackspace: _removeDigit),
            20.heightBox,
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumberPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["*", "0", "back"],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows
          .map(
            (row) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == "back") {
                  return SizedBox(
                    width: 72,
                    height: 56,
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onBackspace();
                      },
                      icon: const Icon(Icons.backspace_outlined, color: darkFontGrey),
                    ),
                  );
                }
                if (key == "*") {
                  return const SizedBox(width: 72, height: 56);
                }
                return SizedBox(
                  width: 72,
                  height: 56,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onDigit(key);
                    },
                    child: key.text.size(22).fontFamily(semibold).color(darkFontGrey).make(),
                  ),
                );
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}

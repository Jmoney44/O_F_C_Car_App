import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/services/pin_service.dart';

/// Reusable PIN-confirmation gate used before completing a payment or a
/// wallet top-up. Validates against the PIN saved by CreatePinScreen —
/// a real local check. If the user never set a PIN, entering any 4
/// digits is accepted (so users who skipped setup aren't locked out).
class EnterPinScreen extends StatefulWidget {
  final String instruction;
  final VoidCallback onVerified;

  const EnterPinScreen({
    super.key,
    required this.instruction,
    required this.onVerified,
  });

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  String pin = "";
  var isChecking = false;

  void _addDigit(String digit) {
    if (pin.length < 4 && !isChecking) {
      setState(() => pin += digit);
      if (pin.length == 4) _verify();
    }
  }

  void _removeDigit() {
    if (pin.isNotEmpty) setState(() => pin = pin.substring(0, pin.length - 1));
  }

  Future<void> _verify() async {
    setState(() => isChecking = true);
    final hasPin = await PinService.hasPin();
    final valid = !hasPin || await PinService.verifyPin(pin);
    if (!mounted) return;
    if (valid) {
      widget.onVerified();
    } else {
      VxToast.show(context, msg: "Incorrect PIN");
      setState(() {
        pin = "";
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: enterYourPin.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            40.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: widget.instruction.text.center.color(fontGrey).size(14).make(),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final row in const [
                  ["1", "2", "3"],
                  ["4", "5", "6"],
                  ["7", "8", "9"],
                  ["*", "0", "back"],
                ])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((key) {
                      if (key == "back") {
                        return SizedBox(
                          width: 72,
                          height: 56,
                          child: IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _removeDigit();
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
                            _addDigit(key);
                          },
                          child: key.text.size(22).fontFamily(semibold).color(darkFontGrey).make(),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
            20.heightBox,
          ],
        ),
      ),
    );
  }
}

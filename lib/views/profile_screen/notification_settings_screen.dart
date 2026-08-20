import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKeys = [
  "notif_general",
  "notif_sound",
  "notif_vibrate",
  "notif_special_offers",
  "notif_promo",
  "notif_payments",
  "notif_cashback",
  "notif_app_updates",
  "notif_new_service",
  "notif_new_tips",
];
const _prefLabels = [
  generalNotification,
  sound,
  vibrate,
  specialOffers,
  promoAndDiscount,
  payments,
  cashback,
  appUpdates,
  newServiceAvailable,
  newTipsAvailable,
];
// Sensible defaults matching the design reference.
const _prefDefaults = [true, true, false, true, false, true, false, true, false, false];

/// Real local persistence via shared_preferences — but these toggles
/// don't gate any actual push notifications, since no FCM setup exists
/// in this project.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  Map<String, bool> values = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <String, bool>{};
    for (var i = 0; i < _prefKeys.length; i++) {
      loaded[_prefKeys[i]] = prefs.getBool(_prefKeys[i]) ?? _prefDefaults[i];
    }
    if (mounted) setState(() => values = loaded);
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() => values[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: notificationLabel.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: values.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _prefKeys.length,
              itemBuilder: (context, index) {
                final key = _prefKeys[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _prefLabels[index].text.color(darkFontGrey).make(),
                      Switch(
                        value: values[key] ?? false,
                        activeThumbColor: whiteColor,
                        activeTrackColor: primaryColor,
                        onChanged: (v) => _set(key, v),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

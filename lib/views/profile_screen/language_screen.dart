import 'package:flutter/material.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = "selected_language";
const _suggested = ["English (US)", "English (UK)"];
const _others = [
  "Mandarin", "Hindi", "Spanish", "French", "Arabic", "Bengali", "Russian", "Indonesia"
];

/// Persisted locally for real, but selecting a language doesn't actually
/// retranslate the app's content — there's no i18n infrastructure here.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selected = "English (US)";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    if (saved != null && mounted) setState(() => selected = saved);
  }

  Future<void> _select(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    setState(() => selected = language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: languageLabel.text.fontFamily(bold).color(darkFontGrey).make(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          "Suggested".text.fontFamily(semibold).color(fontGrey).size(13).make(),
          8.heightBox,
          ..._suggested.map(_row),
          const Divider(height: 24, color: textfieldGrey),
          "Language".text.fontFamily(semibold).color(fontGrey).size(13).make(),
          8.heightBox,
          ..._others.map(_row),
        ],
      ),
    );
  }

  Widget _row(String language) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: language.text.color(darkFontGrey).make(),
      trailing: Icon(
        selected == language ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected == language ? primaryColor : textfieldGrey,
      ),
      onTap: () => _select(language),
    );
  }
}

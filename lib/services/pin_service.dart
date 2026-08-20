import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only PIN storage (not bank-grade security — just a real check
/// instead of a decorative one, scoped per signed-in user).
class PinService {
  static String _key() => "user_pin_${currentUser?.uid}";

  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(), pin);
  }

  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key()) != null;
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key()) == pin;
  }
}

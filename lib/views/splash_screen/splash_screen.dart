import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/consts/firebase_consts.dart';
import 'package:ofcluxury_app/views/auth_screen/lets_you_in_screen.dart';
import 'package:ofcluxury_app/views/home_screen/home.dart';
import 'package:ofcluxury_app/views/onboarding_screen/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //creating a method to change screen

  changeScreen() {
    Future.delayed(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(hasSeenOnboardingKey) ?? false;

      auth.authStateChanges().listen((User? user) {
        if (!mounted) return;
        if (user == null) {
          if (hasSeenOnboarding) {
            Get.off(() => const LetsYouInScreen());
          } else {
            Get.off(() => const WelcomeScreen());
          }
        } else {
          Get.off(() => const Home());
        }
      });
    });
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Icon(Icons.time_to_leave_rounded, size: 110, color: darkFontGrey),
            Spacer(flex: 4),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

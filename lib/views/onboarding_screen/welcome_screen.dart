import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/onboarding_screen/onboarding_screen.dart';

/// Full-bleed welcome interstitial shown once, right after Splash,
/// before the swipeable onboarding pager. No bundled car photography
/// exists in this project's assets, so the hero look is recreated with
/// a dusk-toned gradient sky + a car silhouette instead of a photo.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _continue);
  }

  void _continue() {
    if (mounted) Get.off(() => const OnboardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _continue,
      child: Scaffold(
        backgroundColor: const Color(0xFF23262E),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8A87C), // dusk orange
                Color(0xFFC38D9E), // mauve
                Color(0xFF6E6C8A), // hazy purple
                Color(0xFF3A3D52),
                Color(0xFF16171B),
              ],
              stops: [0.0, 0.25, 0.48, 0.72, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // hazy mountain silhouette
              Positioned(
                left: 0,
                right: 0,
                bottom: 260,
                child: Opacity(
                  opacity: 0.35,
                  child: ClipPath(
                    clipper: _MountainClipper(),
                    child: Container(height: 90, color: whiteColor),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.05),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  size: 190,
                  color: whiteColor.withValues(alpha: 0.92),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 56),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      welcomeWave.text.fontFamily(semibold).color(whiteColor).size(18).make(),
                      6.heightBox,
                      appname.text.fontFamily(extraBold).color(whiteColor).size(34).make(),
                      10.heightBox,
                      welcomeSubtitle.text
                          .color(whiteColor.withValues(alpha: 0.75))
                          .size(14)
                          .make(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MountainClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.18, size.height * 0.15);
    path.lineTo(size.width * 0.32, size.height * 0.45);
    path.lineTo(size.width * 0.5, size.height * 0.05);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

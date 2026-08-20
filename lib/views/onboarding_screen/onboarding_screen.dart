import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ofcluxury_app/consts/consts.dart';
import 'package:ofcluxury_app/views/auth_screen/lets_you_in_screen.dart';
import 'package:ofcluxury_app/views/widgets_common/our_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    _OnboardSlideData(
      title: onboardTitle1,
      titleBold: onboardTitle1Bold,
      subtitle: onboardSubtitle1,
    ),
    _OnboardSlideData(
      title: onboardTitle2,
      titleBold: onboardTitle2Bold,
      subtitle: onboardSubtitle2,
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenOnboardingKey, true);
    if (mounted) Get.offAll(() => const LetsYouInScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: skip.text
                    .fontFamily(semibold)
                    .color(fontGrey)
                    .make()
                    .onTap(_finishOnboarding),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              const Positioned(
                                top: 0,
                                child: Icon(
                                  Icons.directions_car_rounded,
                                  size: 140,
                                  color: darkFontGrey,
                                ),
                              ),
                              Positioned(
                                bottom: 26,
                                child: Container(
                                  width: 190,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: textfieldGrey, width: 1.5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: "360°".text.color(whiteColor).fontFamily(semibold).size(12).make(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        24.heightBox,
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(fontFamily: extraBold, fontSize: 28, color: darkFontGrey, height: 1.2),
                            children: [
                              TextSpan(text: "${slide.title} "),
                              TextSpan(text: slide.titleBold, style: const TextStyle(color: primaryColor)),
                            ],
                          ),
                        ),
                        16.heightBox,
                        slide.subtitle.text
                            .center
                            .color(fontGrey)
                            .size(15)
                            .make(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == _currentPage ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage ? primaryColor : textfieldGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            30.heightBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ourButton(
                title: isLast ? getStarted : next,
                color: primaryColor,
                textColor: whiteColor,
                onPress: () {
                  if (isLast) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            30.heightBox,
          ],
        ),
      ),
    );
  }
}

class _OnboardSlideData {
  final String title;
  final String titleBold;
  final String subtitle;

  const _OnboardSlideData({
    required this.title,
    required this.titleBold,
    required this.subtitle,
  });
}

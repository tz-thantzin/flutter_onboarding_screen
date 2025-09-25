import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/onboarding.dart';
import '../home/home_page.dart';
import 'onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_completed", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// PageView with swipe
            PageView.builder(
              controller: _controller,
              onPageChanged: (value) => setState(() => _currentPage = value),
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final item = contents[index];

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double pageOffset = 0;
                    if (_controller.hasClients) {
                      pageOffset =
                          _controller.page ??
                          _controller.initialPage.toDouble();
                    }
                    double delta = index - pageOffset;
                    double scale = 1 - (delta.abs() * 0.2);
                    double translate = delta * 50;

                    return Transform.translate(
                      offset: Offset(translate, 0),
                      child: Transform.scale(
                        scale: scale.clamp(0.8, 1.0),
                        child: OnboardingContent(
                          image: item.image,
                          title: item.title,
                          desc: item.desc,
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            /// Skip Button (Top-right)
            Positioned(
              top: 20,
              right: 20,
              child: TextButton(
                onPressed: () => _controller.jumpToPage(contents.length - 1),
                child: const Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// Bottom Controls + Dot indicators
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Dot indicators with animated size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 5),
                        height: 10,
                        width: _currentPage == index ? 20 : 10,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Back / Next / Start Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage == 0
                          ? const SizedBox(width: 70)
                          : ElevatedButton(
                              onPressed: () => _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: const Text("BACK"),
                            ),
                      _currentPage == contents.length - 1
                          ? ElevatedButton(
                              onPressed: _completeOnboarding,
                              child: const Text("START"),
                            )
                          : ElevatedButton(
                              onPressed: () => _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: const Text("NEXT"),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

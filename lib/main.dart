import 'package:flutter/material.dart';
import 'package:flutter_onboarding_screen/ui/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool("onboarding_completed") ?? false;

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboardingCompleted ? const HomePage() : const OnboardingScreen(),
    );
  }
}

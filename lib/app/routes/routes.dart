import 'package:flutter/widgets.dart';
import 'package:the_daily_israel/app/app.dart';
import 'package:the_daily_israel/home/home.dart';
import 'package:the_daily_israel/onboarding/onboarding.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.onboardingRequired:
      return [OnboardingPage.page()];
    case AppStatus.unauthenticated:
    case AppStatus.authenticated:
      return [HomePage.page()];
  }
}

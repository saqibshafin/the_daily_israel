// ignore_for_file: prefer_const_constructors

import 'package:the_daily_israel/onboarding/onboarding.dart';
import 'package:test/test.dart';

void main() {
  group('OnboardingEvent', () {
    group('EnableAdTrackingRequested', () {
      test('supports value comparisons', () {
        final event1 = EnableAdTrackingRequested();
        final event2 = EnableAdTrackingRequested();
        expect(event1, equals(event2));
      });
    });

    group('EnableNotificationsRequested', () {
      test('supports value comparisons', () {
        final event1 = EnableNotificationsRequested();
        final event2 = EnableNotificationsRequested();
        expect(event1, equals(event2));
      });
    });
  });
}

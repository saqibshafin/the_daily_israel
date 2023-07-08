import 'package:the_daily_israel/analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsState', () {
    group('AnalyticsInitial', () {
      test('supports value comparisons', () {
        expect(AnalyticsInitial(), AnalyticsInitial());
      });
    });
  });
}

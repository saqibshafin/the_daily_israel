import 'package:the_daily_israel/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SearchHeadlineText', () {
    testWidgets('renders headerText uppercased', (tester) async {
      await tester.pumpApp(
        const SearchHeadlineText(
          headerText: 'text',
        ),
      );

      expect(find.text('TEXT'), findsOneWidget);
    });
  });
}

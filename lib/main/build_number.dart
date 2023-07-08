import 'package:the_daily_israel/src/version.dart';

int buildNumber([String version = packageVersion]) {
  final versionSegments = version.split('+');
  if (versionSegments.isEmpty) return 0;
  return int.tryParse(versionSegments.last) ?? 0;
}

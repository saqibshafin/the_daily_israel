import 'package:dart_frog/dart_frog.dart';
import 'package:the_daily_israel_api/api.dart';

final _newsDataSource = InMemoryNewsDataSource();

/// Provider a [NewsDataSource] to the current [RequestContext].
Middleware newsDataSourceProvider() {
  return (handler) {
    return handler.use(provider<NewsDataSource>((_) => _newsDataSource));
  };
}

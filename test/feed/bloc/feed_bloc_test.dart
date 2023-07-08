// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:bloc_test/bloc_test.dart';
import 'package:the_daily_israel/feed/feed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_blocks/news_blocks.dart';
import 'package:news_repository/news_repository.dart';

import '../../helpers/helpers.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  initMockHydratedStorage();

  group('FeedBloc', () {
    late NewsRepository newsRepository;
    late FeedBloc feedBloc;

    final feedResponse = FeedResponse(
      feed: [
        SectionHeaderBlock(title: 'title'),
        DividerHorizontalBlock(),
      ],
      totalCount: 4,
    );

    final feedStatePopulated = FeedState(
      status: FeedStatus.populated,
      feed: {
        Category.entertainment: [
          SpacerBlock(spacing: Spacing.medium),
          DividerHorizontalBlock(),
        ],
        Category.health: [
          DividerHorizontalBlock(),
        ],
      },
      hasMoreNews: {
        Category.entertainment: true,
        Category.health: false,
      },
    );

    setUp(() async {
      newsRepository = MockNewsRepository();
      feedBloc = FeedBloc(newsRepository: newsRepository);
    });

    test('can be (de)serialized', () {
      final serialized = feedBloc.toJson(feedStatePopulated);
      final deserialized = feedBloc.fromJson(serialized!);

      expect(deserialized, feedStatePopulated);
    });

    group('FeedRequested', () {
      blocTest<FeedBloc, FeedState>(
        'emits [loading, populated] '
        'when getFeed succeeds '
        'and there are more news to fetch',
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => feedResponse),
        build: () => feedBloc,
        act: (bloc) => bloc.add(
          FeedRequested(category: Category.entertainment),
        ),
        expect: () => <FeedState>[
          FeedState(status: FeedStatus.loading),
          FeedState(
            status: FeedStatus.populated,
            feed: {
              Category.entertainment: feedResponse.feed,
            },
            hasMoreNews: {
              Category.entertainment: true,
            },
          ),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'emits [loading, populated] '
        'with appended feed for the given category '
        'when getFeed succeeds '
        'and there are no more news to fetch',
        seed: () => feedStatePopulated,
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => feedResponse),
        build: () => feedBloc,
        act: (bloc) => bloc.add(
          FeedRequested(category: Category.entertainment),
        ),
        expect: () => <FeedState>[
          feedStatePopulated.copyWith(status: FeedStatus.loading),
          feedStatePopulated.copyWith(
            status: FeedStatus.populated,
            feed: feedStatePopulated.feed
              ..addAll({
                Category.entertainment: [
                  ...feedStatePopulated.feed[Category.entertainment]!,
                  ...feedResponse.feed,
                ],
              }),
            hasMoreNews: feedStatePopulated.hasMoreNews
              ..addAll({
                Category.entertainment: false,
              }),
          )
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'emits [loading, error] '
        'when getFeed fails',
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception()),
        build: () => feedBloc,
        act: (bloc) => bloc.add(
          FeedRequested(category: Category.entertainment),
        ),
        expect: () => <FeedState>[
          FeedState(status: FeedStatus.loading),
          FeedState(status: FeedStatus.failure),
        ],
      );
    });

    group('FeedRefreshRequested', () {
      blocTest<FeedBloc, FeedState>(
        'emits [loading, populated] '
        'when getFeed succeeds '
        'and there is more news to fetch',
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => feedResponse),
        build: () => feedBloc,
        act: (bloc) => bloc.add(
          FeedRefreshRequested(category: Category.entertainment),
        ),
        expect: () => <FeedState>[
          FeedState(status: FeedStatus.loading),
          FeedState(
            status: FeedStatus.populated,
            feed: {
              Category.entertainment: feedResponse.feed,
            },
            hasMoreNews: {
              Category.entertainment: true,
            },
          ),
        ],
      );

      blocTest<FeedBloc, FeedState>(
        'emits [loading, error] '
        'when getFeed fails',
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception()),
        build: () => feedBloc,
        act: (bloc) => bloc.add(
          FeedRefreshRequested(category: Category.entertainment),
        ),
        expect: () => <FeedState>[
          FeedState(status: FeedStatus.loading),
          FeedState(status: FeedStatus.failure),
        ],
      );
    });

    group('FeedResumed', () {
      blocTest<FeedBloc, FeedState>(
        'emits [populated] '
        'when getFeed succeeds '
        'and there are more news to fetch for a single category',
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => feedResponse),
        build: () => feedBloc,
        seed: () => FeedState(
          status: FeedStatus.populated,
          feed: {Category.top: []},
        ),
        act: (bloc) => bloc.add(FeedResumed()),
        expect: () => <FeedState>[
          FeedState(
            status: FeedStatus.populated,
            feed: {
              Category.top: feedResponse.feed,
            },
            hasMoreNews: {
              Category.top: true,
            },
          ),
        ],
        verify: (_) {
          verify(
            () => newsRepository.getFeed(
              category: Category.top,
              offset: 0,
            ),
          ).called(1);
        },
      );

      blocTest<FeedBloc, FeedState>(
        'emits [populated] '
        'when getFeed succeeds '
        'and there are more news to fetch for multiple category',
        setUp: () => when(
          () => newsRepository.getFeed(
            category: any(named: 'category'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => feedResponse),
        build: () => feedBloc,
        seed: () => FeedState(
          status: FeedStatus.populated,
          feed: {Category.top: [], Category.technology: []},
        ),
        act: (bloc) => bloc.add(FeedResumed()),
        expect: () => <FeedState>[
          FeedState(
            status: FeedStatus.populated,
            feed: {
              Category.top: feedResponse.feed,
              Category.technology: [],
            },
            hasMoreNews: {
              Category.top: true,
            },
          ),
          FeedState(
            status: FeedStatus.populated,
            feed: {
              Category.top: feedResponse.feed,
              Category.technology: feedResponse.feed,
            },
            hasMoreNews: {
              Category.top: true,
              Category.technology: true,
            },
          ),
        ],
        verify: (_) {
          verify(
            () => newsRepository.getFeed(category: Category.top, offset: 0),
          ).called(1);
          verify(
            () => newsRepository.getFeed(
              category: Category.technology,
              offset: 0,
            ),
          ).called(1);
        },
      );
    });
  });
}

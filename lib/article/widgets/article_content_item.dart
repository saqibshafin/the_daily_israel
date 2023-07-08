import 'package:flutter/material.dart' hide Image, Spacer;
import 'package:the_daily_israel/article/article.dart';
import 'package:the_daily_israel/l10n/l10n.dart';
import 'package:the_daily_israel/newsletter/newsletter.dart';
import 'package:the_daily_israel/slideshow/slideshow.dart';
import 'package:news_blocks/news_blocks.dart';
import 'package:news_blocks_ui/news_blocks_ui.dart';

class ArticleContentItem extends StatelessWidget {
  const ArticleContentItem({
    required this.block,
    this.onSharePressed,
    super.key,
  });

  /// The associated [NewsBlock] instance.
  final NewsBlock block;

  /// An optional callback which is invoked when the share button is pressed.
  final VoidCallback? onSharePressed;

  @override
  Widget build(BuildContext context) {
    final newsBlock = block;

    if (newsBlock is DividerHorizontalBlock) {
      return DividerHorizontal(block: newsBlock);
    } else if (newsBlock is SpacerBlock) {
      return Spacer(block: newsBlock);
    } else if (newsBlock is ImageBlock) {
      return Image(block: newsBlock);
    } else if (newsBlock is VideoBlock) {
      return Video(block: newsBlock);
    } else if (newsBlock is TextCaptionBlock) {
      final articleThemeColors =
          Theme.of(context).extension<ArticleThemeColors>()!;
      return TextCaption(
        block: newsBlock,
        colorValues: {
          TextCaptionColor.normal: articleThemeColors.captionNormal,
          TextCaptionColor.light: articleThemeColors.captionLight,
        },
      );
    } else if (newsBlock is TextHeadlineBlock) {
      return TextHeadline(block: newsBlock);
    } else if (newsBlock is TextLeadParagraphBlock) {
      return TextLeadParagraph(block: newsBlock);
    } else if (newsBlock is TextParagraphBlock) {
      return TextParagraph(block: newsBlock);
    } else if (newsBlock is ArticleIntroductionBlock) {
      return ArticleIntroduction(
        block: newsBlock,
        premiumText: context.l10n.newsBlockPremiumText,
      );
    } else if (newsBlock is VideoIntroductionBlock) {
      return VideoIntroduction(block: newsBlock);
    } else if (newsBlock is BannerAdBlock) {
      return BannerAd(
        block: newsBlock,
        adFailedToLoadTitle: context.l10n.adLoadFailure,
      );
    } else if (newsBlock is NewsletterBlock) {
      return const Newsletter();
    } else if (newsBlock is HtmlBlock) {
      return Html(block: newsBlock);
    } else if (newsBlock is TrendingStoryBlock) {
      return TrendingStory(
        block: newsBlock,
        title: context.l10n.trendingStoryTitle,
      );
    } else if (newsBlock is SlideshowIntroductionBlock) {
      return SlideshowIntroduction(
        block: newsBlock,
        slideshowText: context.l10n.slideshow,
        onPressed: (action) => _onContentItemAction(context, action),
      );
    } else {
      // Render an empty widget for the unsupported block type.
      return const SizedBox();
    }
  }

  /// Handles actions triggered by tapping on article content items.
  Future<void> _onContentItemAction(
    BuildContext context,
    BlockAction action,
  ) async {
    if (action is NavigateToSlideshowAction) {
      await Navigator.of(context).push<void>(
        SlideshowPage.route(
          slideshow: action.slideshow,
          articleId: action.articleId,
        ),
      );
    }
  }
}

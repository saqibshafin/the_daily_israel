import 'package:app_ui/app_ui.dart'
    show AppButton, AppColors, AppSpacing, Assets, showAppModal;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_daily_israel/ads/ads.dart';
import 'package:the_daily_israel/analytics/analytics.dart';
import 'package:the_daily_israel/app/app.dart';
import 'package:the_daily_israel/article/article.dart';
import 'package:the_daily_israel/l10n/l10n.dart';
import 'package:the_daily_israel/login/login.dart';
import 'package:the_daily_israel/subscriptions/subscriptions.dart';
import 'package:visibility_detector/visibility_detector.dart';

@visibleForTesting
class SubscribeWithArticleLimitModal extends StatefulWidget {
  const SubscribeWithArticleLimitModal({super.key});

  @override
  State<SubscribeWithArticleLimitModal> createState() =>
      _SubscribeWithArticleLimitModalState();
}

class _SubscribeWithArticleLimitModalState
    extends State<SubscribeWithArticleLimitModal> {
  bool _modalShown = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isLoggedIn =
        context.select((AppBloc bloc) => bloc.state.status.isLoggedIn);

    final articleTitle = context.select((ArticleBloc bloc) => bloc.state.title);

    final watchVideoButtonTitle =
        l10n.subscribeWithArticleLimitModalWatchVideoButton;

    return VisibilityDetector(
      key: const Key('subscribeWithArticleLimitModal_visibilityDetector'),
      onVisibilityChanged: _modalShown
          ? null
          : (visibility) {
              if (!visibility.visibleBounds.isEmpty) {
                context.read<AnalyticsBloc>().add(
                      TrackAnalyticsEvent(
                        PaywallPromptEvent.impression(
                          impression: PaywallPromptImpression.rewarded,
                          articleTitle: articleTitle ?? '',
                        ),
                      ),
                    );
                setState(() => _modalShown = true);
              }
            },
      child: ColoredBox(
        color: AppColors.darkBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
                child: Text(
                  l10n.subscribeWithArticleLimitModalTitle,
                  style: theme.textTheme.displaySmall
                      ?.apply(color: AppColors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
                child: Text(
                  l10n.subscribeWithArticleLimitModalSubtitle,
                  style: theme.textTheme.titleMedium
                      ?.apply(color: AppColors.mediumEmphasisPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg + AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg + AppSpacing.xxs,
                ),
                child: AppButton.redWine(
                  key: const Key(
                    'subscribeWithArticleLimitModal_subscribeButton',
                  ),
                  child: Text(l10n.subscribeButtonText),
                  onPressed: () {
                    showPurchaseSubscriptionDialog(context: context);
                    context.read<AnalyticsBloc>().add(
                          TrackAnalyticsEvent(
                            PaywallPromptEvent.click(
                              articleTitle: articleTitle ?? '',
                            ),
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!isLoggedIn) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg + AppSpacing.xxs,
                  ),
                  child: AppButton.outlinedTransparentWhite(
                    key:
                        const Key('subscribeWithArticleLimitModal_logInButton'),
                    child: Text(l10n.subscribeWithArticleLimitModalLogInButton),
                    onPressed: () => showAppModal<void>(
                      context: context,
                      builder: (context) => const LoginModal(),
                      routeSettings: const RouteSettings(name: LoginModal.name),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg + AppSpacing.xxs,
                ),
                child: AppButton.transparentWhite(
                  key: const Key(
                    'subscribeWithArticleLimitModal_watchVideoButton',
                  ),
                  onPressed: () => context
                      .read<FullScreenAdsBloc>()
                      .add(const ShowRewardedAdRequested()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.icons.video.svg(),
                      const SizedBox(width: AppSpacing.sm),
                      Text(watchVideoButtonTitle),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

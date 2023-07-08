import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:the_daily_israel/l10n/l10n.dart';
import 'package:the_daily_israel/subscriptions/subscriptions.dart';

class NavDrawerSubscribe extends StatelessWidget {
  const NavDrawerSubscribe({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        NavDrawerSubscribeTitle(),
        NavDrawerSubscribeSubtitle(),
        SizedBox(height: AppSpacing.xlg),
        NavDrawerSubscribeButton(),
      ],
    );
  }
}

@visibleForTesting
class NavDrawerSubscribeTitle extends StatelessWidget {
  const NavDrawerSubscribeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg + AppSpacing.xxs,
        ),
        child: Text(
          context.l10n.navigationDrawerSubscribeTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.highEmphasisPrimary,
              ),
        ),
      ),
    );
  }
}

@visibleForTesting
class NavDrawerSubscribeSubtitle extends StatelessWidget {
  const NavDrawerSubscribeSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
      ),
      child: Text(
        context.l10n.navigationDrawerSubscribeSubtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumEmphasisPrimary,
            ),
      ),
    );
  }
}

@visibleForTesting
class NavDrawerSubscribeButton extends StatelessWidget {
  const NavDrawerSubscribeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton.redWine(
      onPressed: () => showPurchaseSubscriptionDialog(context: context),
      child: Text(context.l10n.subscribeButtonText),
    );
  }
}

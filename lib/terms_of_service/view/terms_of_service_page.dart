import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:the_daily_israel/l10n/l10n.dart';
import 'package:the_daily_israel/terms_of_service/terms_of_service.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const TermsOfServicePage(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TermsOfServiceHeader(),
          TermsOfServiceBody(
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xlg,
              vertical: AppSpacing.xs,
            ),
          ),
          SizedBox(height: AppSpacing.lg)
        ],
      ),
    );
  }
}

@visibleForTesting
class TermsOfServiceHeader extends StatelessWidget {
  const TermsOfServiceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xlg,
        vertical: AppSpacing.lg,
      ),
      child: Text(
        context.l10n.termsOfServiceModalTitle,
        style: theme.textTheme.headlineMedium,
      ),
    );
  }
}

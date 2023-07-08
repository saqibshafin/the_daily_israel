import 'package:app_ui/app_ui.dart' show AppSpacing, Assets, showAppModal;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_daily_israel/app/app.dart';
import 'package:the_daily_israel/l10n/l10n.dart';
import 'package:the_daily_israel/login/login.dart';
import 'package:the_daily_israel/user_profile/user_profile.dart';

/// A user profile button which displays a [LoginButton]
/// for the unauthenticated user or an [OpenProfileButton]
/// for the authenticated user.
class UserProfileButton extends StatelessWidget {
  const UserProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isAnonymous = context.select<AppBloc, bool>(
      (bloc) => bloc.state.user.isAnonymous,
    );

    return isAnonymous ? const LoginButton() : const OpenProfileButton();
  }
}

@visibleForTesting
class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Assets.icons.logInIcon.svg(),
      iconSize: 24,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      onPressed: () => showAppModal<void>(
        context: context,
        builder: (context) => const LoginModal(),
        routeSettings: const RouteSettings(name: LoginModal.name),
      ),
      tooltip: context.l10n.loginTooltip,
    );
  }
}

@visibleForTesting
class OpenProfileButton extends StatelessWidget {
  const OpenProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Assets.icons.profileIcon.svg(),
      iconSize: 24,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      onPressed: () => Navigator.of(context).push(UserProfilePage.route()),
      tooltip: context.l10n.openProfileTooltip,
    );
  }
}

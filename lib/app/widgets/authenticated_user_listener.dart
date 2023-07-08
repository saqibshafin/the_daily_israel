import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_daily_israel/analytics/analytics.dart';
import 'package:the_daily_israel/app/app.dart';

class AuthenticatedUserListener extends StatelessWidget {
  const AuthenticatedUserListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.status.isLoggedIn) {
          context.read<AnalyticsBloc>().add(
                TrackAnalyticsEvent(
                  state.user.isNewUser ? RegistrationEvent() : LoginEvent(),
                ),
              );
        }
      },
      listenWhen: (previous, current) => previous.status != current.status,
      child: child,
    );
  }
}

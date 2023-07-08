import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:the_daily_israel_api/client.dart';
import 'package:notifications_client/notifications_client.dart';
import 'package:permission_client/permission_client.dart';
import 'package:storage/storage.dart';

part 'notifications_storage.dart';

/// {@template notifications_failure}
/// A base failure for the notifications repository failures.
/// {@endtemplate}
abstract class NotificationsFailure with EquatableMixin implements Exception {
  /// {@macro notifications_failure}
  const NotificationsFailure(this.error);

  /// The error which was caught.
  final Object error;

  @override
  List<Object> get props => [error];
}

/// {@template initialize_categories_preferences_failure}
/// Thrown when initializing categories preferences fails.
/// {@endtemplate}
class InitializeCategoriesPreferencesFailure extends NotificationsFailure {
  /// {@macro initialize_categories_preferences_failure}
  const InitializeCategoriesPreferencesFailure(super.error);
}

/// {@template toggle_notifications_failure}
/// Thrown when toggling notifications fails.
/// {@endtemplate}
class ToggleNotificationsFailure extends NotificationsFailure {
  /// {@macro toggle_notifications_failure}
  const ToggleNotificationsFailure(super.error);
}

/// {@template fetch_notifications_enabled_failure}
/// Thrown when fetching a notifications enabled status fails.
/// {@endtemplate}
class FetchNotificationsEnabledFailure extends NotificationsFailure {
  /// {@macro fetch_notifications_enabled_failure}
  const FetchNotificationsEnabledFailure(super.error);
}

/// {@template set_categories_preferences_failure}
/// Thrown when setting categories preferences fails.
/// {@endtemplate}
class SetCategoriesPreferencesFailure extends NotificationsFailure {
  /// {@macro set_categories_preferences_failure}
  const SetCategoriesPreferencesFailure(super.error);
}

/// {@template fetch_categories_preferences_failure}
/// Thrown when fetching categories preferences fails.
/// {@endtemplate}
class FetchCategoriesPreferencesFailure extends NotificationsFailure {
  /// {@macro fetch_categories_preferences_failure}
  const FetchCategoriesPreferencesFailure(super.error);
}

/// {@template notifications_repository}
/// A repository that manages notification permissions and topic subscriptions.
///
/// Access to the device's notifications can be toggled with
/// [toggleNotifications] and checked with [fetchNotificationsEnabled].
///
/// Notification preferences for topic subscriptions related to news categories
/// may be updated with [setCategoriesPreferences] and checked with
/// [fetchCategoriesPreferences].
/// {@endtemplate}
class NotificationsRepository {
  /// {@macro notifications_repository}
  NotificationsRepository({
    required PermissionClient permissionClient,
    required NotificationsStorage storage,
    required NotificationsClient notificationsClient,
    required TheDailyIsraelApiClient apiClient,
  })  : _permissionClient = permissionClient,
        _storage = storage,
        _notificationsClient = notificationsClient,
        _apiClient = apiClient {
    unawaited(_initializeCategoriesPreferences());
  }

  final PermissionClient _permissionClient;
  final NotificationsStorage _storage;
  final NotificationsClient _notificationsClient;
  final TheDailyIsraelApiClient _apiClient;

  /// Toggles the notifications based on the [enable].
  ///
  /// When [enable] is true, request the notification permission if not granted
  /// and marks the notification setting as enabled. Subscribes the user to
  /// notifications related to user's categories preferences.
  ///
  /// When [enable] is false, marks notification setting as disabled and
  /// unsubscribes the user from notifications related to user's categories
  /// preferences.
  Future<void> toggleNotifications({required bool enable}) async {
    try {
      // Request the notification permission when turning notifications on.
      if (enable) {
        // Find the current notification permission status.
        final permissionStatus = await _permissionClient.notificationsStatus();

        // Navigate the user to permission settings
        // if the permission status is permanently denied or restricted.
        if (permissionStatus.isPermanentlyDenied ||
            permissionStatus.isRestricted) {
          await _permissionClient.openPermissionSettings();
          return;
        }

        // Request the permission if the permission status is denied.
        if (permissionStatus.isDenied) {
          final updatedPermissionStatus =
              await _permissionClient.requestNotifications();
          if (!updatedPermissionStatus.isGranted) {
            return;
          }
        }
      }

      // Toggle categories preferences notification subscriptions.
      await _toggleCategoriesPreferencesSubscriptions(enable: enable);

      // Update the notifications enabled in Storage.
      await _storage.setNotificationsEnabled(enabled: enable);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ToggleNotificationsFailure(error), stackTrace);
    }
  }

  /// Returns true when the notification permission is granted
  /// and the notification setting is enabled.
  Future<bool> fetchNotificationsEnabled() async {
    try {
      final results = await Future.wait([
        _permissionClient.notificationsStatus(),
        _storage.fetchNotificationsEnabled(),
      ]);

      final permissionStatus = results.first as PermissionStatus;
      final notificationsEnabled = results.last as bool;

      return permissionStatus.isGranted && notificationsEnabled;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FetchNotificationsEnabledFailure(error),
        stackTrace,
      );
    }
  }

  /// Updates the user's notification preferences and subscribes the user to
  /// receive notifications related to [categories].
  ///
  /// [categories] represents a set of categories the user has agreed to
  /// receive notifications from.
  ///
  /// Throws [SetCategoriesPreferencesFailure] when updating fails.
  Future<void> setCategoriesPreferences(Set<Category> categories) async {
    try {
      // Disable notification subscriptions for previous categories preferences.
      await _toggleCategoriesPreferencesSubscriptions(enable: false);

      // Update categories preferences in Storage.
      await _storage.setCategoriesPreferences(categories: categories);

      // Enable notification subscriptions for updated categories preferences.
      if (await fetchNotificationsEnabled()) {
        await _toggleCategoriesPreferencesSubscriptions(enable: true);
      }
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SetCategoriesPreferencesFailure(error),
        stackTrace,
      );
    }
  }

  /// Fetches the user's notification preferences for news categories.
  ///
  /// The result represents a set of categories the user has agreed to
  /// receive notifications from.
  ///
  /// Throws [FetchCategoriesPreferencesFailure] when fetching fails.
  Future<Set<Category>?> fetchCategoriesPreferences() async {
    try {
      return await _storage.fetchCategoriesPreferences();
    } on StorageException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FetchCategoriesPreferencesFailure(error),
        stackTrace,
      );
    }
  }

  /// Toggles notification subscriptions based on user's categories preferences.
  Future<void> _toggleCategoriesPreferencesSubscriptions({
    required bool enable,
  }) async {
    final categoriesPreferences =
        await _storage.fetchCategoriesPreferences() ?? {};
    await Future.wait(
      categoriesPreferences.map((category) {
        return enable
            ? _notificationsClient.subscribeToCategory(category.name)
            : _notificationsClient.unsubscribeFromCategory(category.name);
      }),
    );
  }

  /// Initializes categories preferences to all categories
  /// if they have not been set before.
  Future<void> _initializeCategoriesPreferences() async {
    try {
      final categoriesPreferences = await _storage.fetchCategoriesPreferences();
      if (categoriesPreferences == null) {
        final categoriesResponse = await _apiClient.getCategories();
        await _storage.setCategoriesPreferences(
          categories: categoriesResponse.categories.toSet(),
        );
      }
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        InitializeCategoriesPreferencesFailure(error),
        stackTrace,
      );
    }
  }
}

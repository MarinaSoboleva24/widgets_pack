/// Utilities for interacting with Supabase in the Widgets Pack library.

/// This file provides helper methods to manage widget data and user configurations in a Supabase database.
/// It includes functionality to register widgets, load user-specific configurations, and save updated configurations.
/// These utilities are designed to be used internally by the Widgets Pack library to support [PlatformWidget] subclasses.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A utility class for Supabase operations related to widgets and user configurations.
class SupabaseUtils {
  /// Registers a widget in the Supabase `widgets` table.
  /// This method upserts a widget's metadata into the `widgets` table.
  /// If a widget with the same `id` already exists, it will be updated; otherwise, a new entry will be created.
  ///
  /// [widget] The widget data to register, encapsulated in a [WidgetData] object.
  /// [client] The Supabase client instance to use for the operation.
  ///
  /// Throws an [ArgumentError] if the widget's `id` is empty.
  /// Throws a [SupabaseException] or other exceptions if the Supabase operation fails.
  static Future<void> upsertWidget(
    WidgetData widget,
    SupabaseClient client,
  ) async {
    if (widget.id.isEmpty) {
      throw ArgumentError('Widget ID cannot be empty');
    }

    try {
      final response = await client.from('widgets').upsert({
        'id': widget.id,
        'name': widget.name,
        'description': widget.description,
        'developer_id': widget.developerId,
        'ui_config': widget.uiConfig,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'approved',
      }, onConflict: 'id');

      debugPrint('Widget upserted successfully: ${widget.id}');
      debugPrint('Response: $response');
    } catch (e) {
      debugPrint('Error upserting widget ${widget.id}: $e');
      rethrow;
    }
  }

  /// Loads a user's configuration for a specific widget from the Supabase `users_widgets` table.
  ///
  /// This method retrieves the user-specific configuration for the widget identified by [widgetId].
  /// It requires an authenticated user and queries the `users_widgets` table for a matching entry.
  ///
  /// [widgetId] The unique identifier of the widget whose configuration is to be loaded.
  ///
  /// Returns a [Map<String, dynamic>] containing the user's configuration.
  /// If no configuration is found, an empty map is returned.
  ///
  /// Throws an [ArgumentError] if [widgetId] is empty.
  /// Throws an [Exception] if the user is not authenticated.
  /// Throws a [SupabaseException] or other exceptions if the Supabase operation fails.
  static Future<Map<String, dynamic>> loadUserConfiguration(
    String widgetId,
  ) async {
    if (widgetId.isEmpty) {
      throw ArgumentError('Widget ID cannot be empty');
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        debugPrint('Error: User not authenticated in TimerWidget');
        throw Exception('User not authenticated');
      }

      final response =
          await Supabase.instance.client
              .from('users_widgets')
              .select('custom_config')
              .eq('user_id', user.id)
              .eq('widget_id', widgetId)
              .maybeSingle();

      if (response == null) {
        debugPrint('No entry found for user ${user.id} and widget $widgetId');
        return {};
      }

      return Map<String, dynamic>.from(response['custom_config'] ?? {});
    } catch (e) {
      debugPrint('Error loading custom config: $e');
      rethrow;
    }
  }

  /// Saves a user's configuration for a specific widget to the Supabase `users_widgets` table.
  ///
  /// This method upserts the user's configuration for the widget identified by [widgetId].
  /// It requires an authenticated user and updates the `custom_config` field in the `users_widgets` table.
  ///
  /// [newConfiguration] The updated configuration to save, as a map.
  /// [widgetId] The unique identifier of the widget whose configuration is to be saved.
  ///
  /// Throws an [ArgumentError] if [widgetId] is empty.
  /// Throws an [Exception] if the user is not authenticated.
  /// Throws a [SupabaseException] or other exceptions if the Supabase operation fails.
  static Future<void> saveUserConfiguration(
    Map<String, dynamic> newConfiguration,
    String widgetId,
  ) async {
    if (widgetId.isEmpty) {
      throw ArgumentError('Widget ID cannot be empty');
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await Supabase.instance.client
          .from('users_widgets')
          .update({'custom_config': newConfiguration})
          .eq('user_id', user.id)
          .eq('widget_id', widgetId);
    } catch (e) {
      debugPrint('Error saving user configuration for widget $widgetId: $e');
      rethrow;
    }
  }
}

/// A helper data class to encapsulate widget metadata for Supabase operations.
///
/// This class is used to pass widget data to [SupabaseUtils.upsertWidget] for registration in the Supabase `widgets` table.
class WidgetData {
  final String id;
  final String name;
  final String description;
  final String developerId;
  final Map<String, dynamic> uiConfig;

  WidgetData({
    required this.id,
    required this.name,
    required this.description,
    required this.developerId,
    required this.uiConfig,
  });
}

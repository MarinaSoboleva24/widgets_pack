/// Manages the registry of platform widgets in the Widgets Pack library.
///
/// This file defines the [WidgetRegistry] class, which maintains a list of available [PlatformWidget] instances
/// and provides methods to access and register them with Supabase. It serves as a central hub for managing widgets,
/// ensuring they are properly registered in the Supabase database via [SupabaseUtils].
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widgets_pack/platform_widget.dart';
import 'package:widgets_pack/src/utils/supabase_utils.dart';
import 'package:widgets_pack/src/widgets/taskPlanner.dart';
import 'package:widgets_pack/src/widgets/timer.dart';

/// A registry for managing all available platform widgets.
///
/// The [WidgetRegistry] class maintains a static list of [PlatformWidget] instances and provides methods to access and register them with Supabase.
/// It ensures that all widgets are properly initialized and registered in the Supabase `widgets` table, making them available for use in the app.
/// Widgets are added to the registry by including them in the internal `_widgets` list.
///
class WidgetRegistry {
  /// The internal list of registered platform widgets.
  ///
  /// This list contains all [PlatformWidget] instances available in the app.
  /// New widgets should be added here to make them available for registration and use. For example:
  ///
  /// ```dart
  /// static final List<PlatformWidget> _widgets = [
  ///   TimerWidget(),
  ///   AnotherWidget(),
  /// ];
  /// ```
  static final List<PlatformWidget> _widgets = [
    TimerWidget(),
    TaskPlannerWidget(),
    // Add other widgets here
  ];

  /// Retrieves the list of registered platform widgets.
  ///
  /// Returns a [List<PlatformWidget>] containing all widgets in the registry.
  /// This list is used to display widgets in the app's UI or to perform other operations on the registered widgets.
  static List<PlatformWidget> getWidgets() => _widgets;

  /// Registers all widgets in the registry with Supabase.
  ///
  /// This method iterates through the list of registered widgets and uses [SupabaseUtils.upsertWidget] to register each one in the Supabase `widgets` table.
  /// It is called at app startup after Supabase has been initialized to ensure all widgets are properly registered.
  ///
  /// [client] The Supabase client instance to use for registration.
  ///
  /// Throws an [Exception] if there are duplicate widget IDs in the registry.
  /// Throws a [SupabaseException] or other exceptions if the Supabase operation fails.
  static Future<void> registerAllWidgets(SupabaseClient client) async {
    // Validate unique IDs
    final ids = _widgets.map((w) => w.id).toSet();
    if (ids.length != _widgets.length) {
      throw Exception('Duplicate widget IDs found in registry');
    }

    for (final widget in _widgets) {
      final widgetData = WidgetData(
        id: widget.id,
        name: widget.name,
        description: widget.description,
        developerId: widget.developerId,
        uiConfig: widget.uiConfig,
      );
      await SupabaseUtils.upsertWidget(widgetData, client);
    }
  }
}

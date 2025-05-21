/// Defines the base class for platform widgets in the Widgets Pack library.
///
/// This file provides the [PlatformWidget] abstract class, which serves as the foundation for
/// creating reusable and customizable UI components that can be registered in Supabase.
/// Widgets built with this class are managed by [WidgetRegistry] and interact with Supabase through [SupabaseUtils].
library;

import 'package:flutter/material.dart';

/// Base class for all platform widgets.
///
/// A [PlatformWidget] is a reusable UI component that can be registered in a Supabase database and customized by users.
/// Subclasses must implement the required metadata properties ([id], [name], [description], [developerId], [uiConfig])
/// and override the [build] method to define the widget's UI. This class is used in conjunction with [WidgetRegistry]
/// to manage available widgets and [SupabaseUtils] to handle Supabase interactions.
///
/// Example usage:
///
/// ```dart
/// class MyWidget extends PlatformWidget {
///   @override
///   String get id => '84923c3c-45d7-4d3b-b198-dc689597027a';
///
///   @override
///   String get name => 'My Widget';
///
///   @override
///   String get description => 'This widget is created for demonstration purposes';
///
///   @override
///   String get developerId => '3d603a5f-ec79-4617-ad85-ba2aefe9978d';
///
///   @override
///   Map<String, dynamic> get uiConfig => {'setting': 'value', 'setting2': 'value2', 'setting3': 'value3'};
///
///   @override
///   Widget build(BuildContext context) {
///     print ('It works!');
///     return Text('Hello from MyWidget!');
///   }
/// }
/// ```
///
abstract class PlatformWidget extends StatelessWidget {
  /// Creates a platform widget.
  ///
  /// The [key] parameter is passed to the [StatelessWidget] superclass.
  const PlatformWidget({super.key});

  /// Unique identifier for the widget.
  ///
  /// Must be a valid version 4 UUID (for exapmle, generated via https://www.uuidgenerator.net/).
  /// This ID is used to register the widget in Supabase and should not be empty.
  /// Validation for non-empty values is enforced by [SupabaseUtils].
  String get id;

  /// Display name of the widget.
  ///
  /// This name is shown to users and should be an appropriate and readable string describing the widget.
  String get name;

  /// Description of the widget's purpose and functionality.
  ///
  /// This should provide an overview of what the widget does, suitable for display in a UI.
  String get description;

  /// Identifier of the developer who created the widget.
  ///
  /// Must be an existing version 4 UUID, available upon registration in the platform.
  /// This information can be found on the Profile page under the "Developer Information" section.
  /// Validation for non-empty values is enforced by [SupabaseUtils].
  String get developerId;

  /// Default UI configuration for the widget.
  ///
  /// This map defines the initial configuration that can be customized by users.
  /// It is stored in Supabase and can be overridden by user-specific configurations.
  Map<String, dynamic> get uiConfig;

  /// Builds the widget's UI.
  ///
  /// Subclasses must override this method to define the widget's appearance and behavior.
  /// The returned widget is rendered in the app's UI.
  ///
  /// [context] The build context, provided by Flutter.
  ///
  /// Returns a [Widget] representing the UI of the platform widget.
  @override
  Widget build(BuildContext context);
}

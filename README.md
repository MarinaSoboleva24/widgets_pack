# widgets_pack

A Flutter package designed to support third-party contributions for the FocusFlow productivity platform. This package provides the necessary components for developers to create and integrate widgets, enhancing the platform’s extensibility and fostering community engagement.

## Overview

`widgets_pack` enables developers to contribute widgets by providing:

- An abstract `PlatformWidget` class for consistent widget structure.
- Utilities for Supabase integration (`supabase_utils.dart`).
- Design standards for accessibility and consistency (`app_theme.dart`).
- A registration system for widgets (`widget_registry.dart`).

Widgets created with this package can be seamlessly integrated into the main application, as demonstrated by the included `Timer` and `Task Planner` core widgets.

## Contributing to widgets_pack

We welcome contributions to enhance the platform with new widgets! Below are detailed instructions to guide you through the process.

### Step-by-Step Guide to Contributing New Widgets

1. **Fork and Clone the Repository**  
   Fork this repository and clone it to your local machine:

   ```
   git clone https://github.com/MarinaSoboleva24/widgets_pack.git
   cd widgets_pack
   ```

2. **Set Up Your Development Environment**  
   Ensure all prerequisites (listed below) are installed. Then, install the package dependencies:

   ```
   flutter pub get
   ```

3. **Create a New Widget**

   - Navigate to the `lib/src/widgets/` directory.
   - Create a new Dart file for your widget (e.g., `my_widget.dart`).
   - Implement your widget by extending the `PlatformWidget` class (see instructions below).

4. **Register Your Widget**

   - Open `lib/src/widget_registry.dart`.
   - Add your widget to the static list of `PlatformWidget` instances:
     ```dart
      static final List<PlatformWidget> _widgets = [
     TimerWidget(),
     TaskPlannerWidget(),
     MyWidget() // Add your widget here
     ];
     ```

5. **Test Your Widget**

   - Write unit tests in the `test/` directory (e.g., `test/my_widget_test.dart`).
   - Run tests to ensure functionality:
     ```
     flutter test
     ```

6. **Document Your Code**

   - Add inline documentation to your widget’s code following the guidelines below.
   - Update this `README.md` if your widget introduces new concepts or usage instructions.

7. **Submit a Pull Request**
   - Commit your changes with a clear message (see standards below).
   - Push your branch to your forked repository:
     ```
     git push origin feature/my-widget
     ```
   - Create a pull request (PR) to the `main` branch, adhering to the pull request message standards.

### Prerequisites, Technologies, and Required Data

#### Prerequisites

- **Flutter SDK**: Version 3.0.0 or higher.
- **Dart**: Version 2.17.0 or higher (included with Flutter).
- **IDE**: Visual Studio Code or Android Studio with Flutter plugins installed.
- **Supabase Access**: Obtain the initialized Supabase client from the main application.
- **Git**: For version control and repository management.

#### Technologies

- Flutter: For cross-platform widget development.
- Supabase: For backend database operations.
- Dart: The programming language for widget implementation.

#### Required Data

- **Widget ID**: A unique UUID (generate using an online tool, e.g., `uuidgenerator.net`).
- **Developer ID**: A UUID matching a registered user in the platform’s Supabase database (available in the app's Profile page, under "For developers" section).
- **Widget Metadata**: Includes `name`, `description`, and `uiConfig` (see `PlatformWidget` usage below).

### Standards for Pull Request Messages and Code Comments

#### Pull Request Messages

- **Title**: Use a concise, descriptive title (e.g., "Add MyWidget for task scheduling").
- **Description**:

  - Explain the widget’s purpose and functionality.
  - List any dependencies or prerequisites.
  - Mention breaking changes or impacts on existing functionality.
  - Example:
   ```
    - Implements a new widget for scheduling tasks with a calendar view.
    - Requires no additional dependencies.
    - No breaking changes.
   ```

#### Code Comments

- Use Dart’s documentation comments (`///`) for public classes, methods, and properties.
- Provide clear explanations of functionality, parameters, and return values.
- Example:
  ```dart
  /// A widget for scheduling tasks with a calendar interface.
  class MyWidget extends PlatformWidget {
    /// The unique identifier for this widget.
    @override
    String get id => '123e4567-e89b-12d3-a456-426614174000';
  }
  ```

### Guidelines for Code Documentation, File Structure, and Package Organization

#### Code Documentation

- Document all public classes, methods, and properties using `///`.
- Use clear, concise language.
- Example:
  ```dart
  /// Loads the user's configuration from Supabase.
  /// Returns a map containing the configuration data.
  Future<Map<String, dynamic>> _loadUserConfig() async {
    // Implementation
  }
  ```

#### File Structure

- Place new widgets in `lib/src/widgets/` (e.g., `my_widget.dart`).
- Add utility functions or assets in `lib/src/utils/`.
- Include tests in `test/` (e.g., `my_widget_test.dart`).
- Register your widget in `lib/src/widget_registry.dart`.

#### Package Organization

- Follow the existing structure:
  - `lib/src/widgets/`: Widget implementations.
  - `lib/src/utils/`: Shared utilities (e.g., `supabase_utils.dart`, `app_theme.dart`).
  - `docs/`: Additional documentation.

### Using the Abstract Widget Class and Design Assets

#### Using `PlatformWidget`

1. Extend `PlatformWidget`:

   ```dart
   import 'package:widgets_pack/platform_widget.dart';

   class MyWidget extends PlatformWidget {
     // Implement required properties
   }
   ```

2. Implement the mandatory properties:

   - `id`: Unique UUID.
   - `name`: Short name (e.g., “My Widget”).
   - `description`: Brief overview.
   - `developerId`: Your UUID.
   - `uiConfig`: Default settings map.
   - `build`: Override to define the UI.
     Example:

   ```dart
   @override
   String get id => '123e4567-e89b-12d3-a456-426614174000';

   @override
   String get name => 'My Widget';
   ```

#### Using Design Assets (`app_theme.dart`)

1. Import the file:
   ```dart
   import 'package:widgets_pack/src/utils/app_theme.dart';
   ```
2. Apply predefined styles:
   ```dart
   Text(
     'Title',
     style: TextStyle(
       fontFamily: fontFamily,
       fontSize: titleFontSize,
       color: getTextColor(Theme.of(context).scaffoldBackgroundColor),
     ),
   ),
   ```
3. Use predefined colors (e.g., `vanilla`, `earth`) and constants (e.g., `buttonBorderRadius`).

## Support

For additional help, refer to the `docs/` directory or contact the platform maintainers via the repository’s issue tracker.

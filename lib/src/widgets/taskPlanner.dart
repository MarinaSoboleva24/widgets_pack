import 'dart:async';
import 'package:flutter/material.dart';
import 'package:widgets_pack/platform_widget.dart';
import 'package:widgets_pack/src/utils/supabase_utils.dart';
import 'package:widgets_pack/src/utils/app_theme.dart';

/// A widget for creating and managing a user's task list.
///
/// The [TaskPlannerWidget] allows users to add, edit, delete, and mark tasks as complete.
/// Tasks are stored in a list, and the entire task list along with user preferences (e.g.,
/// sort order) is persisted in Supabase. The widget integrates with [SupabaseUtils] to
/// load and save user configurations.
class TaskPlannerWidget extends PlatformWidget {
  static const String _uuid = 'f5e9d2a1-6b7c-4d3e-9f1a-2c8b3d4e5f6a';
  static const String _developerUuid = 'f58f9822-425c-4430-9da6-42703fc81023';
  const TaskPlannerWidget({super.key});

  @override
  String get id => _uuid;

  @override
  String get name => 'Task Planner';

  @override
  String get description =>
      'A widget to plan and manage your tasks! 📋\nCreate, edit, and track your tasks with ease.';

  @override
  String get developerId => _developerUuid;

  @override
  Map<String, dynamic> get uiConfig => {'tasks': [], 'sortOrder': 'added'};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUserConfig(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading tasks: ${snapshot.error}',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: headerFontSize,
                fontWeight: headerFontWeight,
                color: errorColor,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return preloader;
        }
        return TaskPlannerContent(configuration: snapshot.data!, widgetId: id);
      },
    );
  }

  // Loads the user's configuration from Supabase database
  Future<Map<String, dynamic>> _loadUserConfig() async {
    try {
      final customConfig = await SupabaseUtils.loadUserConfiguration(
        id,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException(
            'Failed to load user configuration from Supabase',
          );
        },
      );

      final tasks =
          (customConfig['tasks'] ?? uiConfig['tasks'] as List)
              .map(
                (task) => {
                  'title': task['title'],
                  'isCompleted': task['isCompleted'] ?? false,
                },
              )
              .toList();
      return {
        'tasks': tasks,
        'sortOrder': customConfig['sortOrder'] ?? uiConfig['sortOrder'],
      };
    } catch (e) {
      debugPrint('Error loading Task Planner configuration: $e');
      return uiConfig;
    }
  }
}

/// The content of the Task Planner widget, managing the stateful task list UI.
class TaskPlannerContent extends StatefulWidget {
  final Map<String, dynamic> configuration;
  final String widgetId;

  const TaskPlannerContent({
    super.key,
    required this.configuration,
    required this.widgetId,
  });

  @override
  State<TaskPlannerContent> createState() => _TaskPlannerContentState();
}

/// State for [TaskPlannerContent], handling the task list and user interactions.
class _TaskPlannerContentState extends State<TaskPlannerContent> {
  late List<Map<String, dynamic>> _tasks;
  late String _sortOrder;
  late TextEditingController _titleController;
  late final Debouncer _debouncer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _tasks = List<Map<String, dynamic>>.from(
      widget.configuration['tasks'] ?? [],
    );
    _sortOrder = widget.configuration['sortOrder'] ?? 'added';
    _titleController = TextEditingController();
    _debouncer = Debouncer(duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  /// Saves the current task list and preferences to Supabase.
  Future<void> _saveConfiguration() async {
    try {
      final updatedConfiguration = {'tasks': _tasks, 'sortOrder': _sortOrder};
      await SupabaseUtils.saveUserConfiguration(
        updatedConfiguration,
        widget.widgetId,
      );
    } catch (e) {
      debugPrint('Error saving TaskPlanner config: $e');
      if (mounted) {
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }

  /// Deletes a task from the list.
  void _deleteTask(int originalIndex) {
    setState(() {
      _tasks.removeAt(originalIndex);
    });
    _debouncer.run(() => _saveConfiguration());
  }

  /// Toggles the completion status of a task.
  void _toggleTaskCompletion(int originalIndex) {
    setState(() {
      _tasks[originalIndex]['isCompleted'] =
          !_tasks[originalIndex]['isCompleted'];
    });
    _debouncer.run(() => _saveConfiguration());
  }

  /// Shows a dialog to add a new task.
  void _showAddTaskDialog() {
    if (_isNavigating) return;

    _titleController.clear();
    _isNavigating = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              _isNavigating = false;
            }
          },
          child: AlertDialog(
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor == vanilla
                    ? vanilla
                    : Colors.grey.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius),
            ),
            title: Text(
              'Add new task',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
                color: earth,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade300,
                    hintText: 'Task name',
                    hintStyle: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: bodyFontSize,
                      fontWeight: bodyFontWeight,
                      color: midColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                      borderSide: BorderSide(color: earth),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                      borderSide: const BorderSide(color: earth, width: 1),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: bodyFontSize,
                    fontWeight: bodyFontWeight,
                    color: earth,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _titleController.clear();
                  _isNavigating = false;
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: bodyFontSize,
                    fontWeight: bodyFontWeight,
                    color: earth,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _addTask(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: earth,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                  elevation: buttonElevation,
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: bodyFontSize,
                    fontWeight: bodyFontWeight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _isNavigating = false;
    });
  }

  /// Adds a new task to the list.
  void _addTask(BuildContext dialogContext) {
    if (_titleController.text.isEmpty) return;

    setState(() {
      _tasks.add({'title': _titleController.text, 'isCompleted': false});
      _titleController.clear();
    });
    _debouncer.run(() => _saveConfiguration());
    Navigator.of(dialogContext).pop();
    _isNavigating = false;
  }

  /// Edits an existing task.
  void _editTask(int originalIndex) {
    if (_isNavigating) return;

    _titleController.text = _tasks[originalIndex]['title'];
    _isNavigating = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              _isNavigating = false;
            }
          },
          child: AlertDialog(
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor == vanilla
                    ? vanilla
                    : Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius),
            ),
            title: Text(
              'Edit Task',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: titleFontSize,
                fontWeight: titleFontWeight,
                color: earth,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade200,
                    hintText: 'Task title',
                    hintStyle: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: bodyFontSize,
                      fontWeight: bodyFontWeight,
                      color: Colors.grey.shade300,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: bodyFontSize,
                    fontWeight: bodyFontWeight,
                    color: earth,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _titleController.clear();
                  _isNavigating = false;
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: bodyFontSize,
                    fontWeight: bodyFontWeight,
                    color: earth,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _editTaskAction(originalIndex, dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: earth,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                  elevation: buttonElevation,
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: bodyFontSize,
                    fontWeight: bodyFontWeight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _isNavigating = false;
    });
  }

  /// Handles the editing an existing task.
  void _editTaskAction(int originalIndex, BuildContext dialogContext) {
    if (_titleController.text.isEmpty) return;

    setState(() {
      _tasks[originalIndex] = {
        'title': _titleController.text,
        'isCompleted': _tasks[originalIndex]['isCompleted'],
      };
    });
    _debouncer.run(() => _saveConfiguration());
    Navigator.of(dialogContext).pop();
    _titleController.clear();
    _isNavigating = false;
  }

  /// Sorts the task list based on the current sort order and returns a list with original indices
  List<Map<String, dynamic>> _sortTasks(List<Map<String, dynamic>> tasks) {
    // Create a copy of the task list to avoid modifying the original data
    final sortedTasks = List<Map<String, dynamic>>.from(tasks);
    // Generate a list of indices to track the original position of each task
    final List<int> indices = List.generate(tasks.length, (index) => index);

    // Sort tasks alphabetically by title using bubble sort
    if (_sortOrder == 'alphabetical') {
      // Iterate through the list to compare adjacent tasks
      for (int i = 0; i < sortedTasks.length - 1; i++) {
        for (int j = 0; j < sortedTasks.length - i - 1; j++) {
          // Compare titles of adjacent tasks: if the current task's title is greater, swap the tasks
          if (sortedTasks[j]['title'].compareTo(sortedTasks[j + 1]['title']) >
              0) {
            // Swap tasks
            final tempTask = sortedTasks[j];
            sortedTasks[j] = sortedTasks[j + 1];
            sortedTasks[j + 1] = tempTask;
            // Swap their indices to keep track of original positions
            final tempIndex = indices[j];
            indices[j] = indices[j + 1];
            indices[j + 1] = tempIndex;
          }
        }
      }
    }
    // Sort tasks by completion status, placing incomplete tasks on top
    else if (_sortOrder == 'completed') {
      // Iterate through the list to compare adjacent tasks
      for (int i = 0; i < sortedTasks.length - 1; i++) {
        for (int j = 0; j < sortedTasks.length - i - 1; j++) {
          // Handle null values for 'isCompleted', default to false if not set
          bool aCompleted = sortedTasks[j]['isCompleted'] ?? false;
          bool bCompleted = sortedTasks[j + 1]['isCompleted'] ?? false;
          // Skip if both tasks have the same status
          if (aCompleted == bCompleted) continue;
          // If the current task is completed and the next is not, swap them to prioritize incomplete tasks
          if (aCompleted && !bCompleted) {
            // Swap tasks
            final tempTask = sortedTasks[j];
            sortedTasks[j] = sortedTasks[j + 1];
            sortedTasks[j + 1] = tempTask;
            // Swap their indices to keep track of original positions
            final tempIndex = indices[j];
            indices[j] = indices[j + 1];
            indices[j + 1] = tempIndex;
          }
        }
      }
    }
    // Add the original index to each task in the sorted list
    for (int i = 0; i < sortedTasks.length; i++) {
      // Create a copy of the task map to avoid modifying the original data
      sortedTasks[i] = Map<String, dynamic>.from(sortedTasks[i]);
      // Add the original index as a new field in the task map
      sortedTasks[i]['originalIndex'] = indices[i];
    }
    return sortedTasks;
  }

  @override
  Widget build(BuildContext context) {
    final sortedTasks = _sortTasks(_tasks);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(spacingUnit * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My tasks',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: titleFontSize,
                        fontWeight: titleFontWeight,
                        color: getTextColor(
                          Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _sortOrder,
                      items: [
                        DropdownMenuItem(
                          value: 'added',
                          child: Text(
                            'Sort by: Added',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: bodyFontSize,
                              fontWeight: bodyFontWeight,
                              color: getTextColor(
                                Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'alphabetical',
                          child: Text(
                            'Sort by: Alphabetical',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: bodyFontSize,
                              fontWeight: bodyFontWeight,
                              color: getTextColor(
                                Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text(
                            'Sort by: Completed',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: bodyFontSize,
                              fontWeight: bodyFontWeight,
                              color: getTextColor(
                                Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortOrder = value;
                          });
                          _debouncer.run(() => _saveConfiguration());
                        }
                      },
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: bodyFontSize,
                        fontWeight: bodyFontWeight,
                        color: getTextColor(
                          Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,

                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: getTextColor(
                          Theme.of(context).scaffoldBackgroundColor,
                        ),
                        size: iconSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacingUnit * 2),
                Expanded(
                  child:
                      sortedTasks.isEmpty
                          ? Center(
                            child: Text(
                              'No tasks yet...\nAdd a task to get started!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: headerFontSize,
                                fontWeight: headerFontWeight,
                                color: midColor,
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: EdgeInsets.only(bottom: spacingUnit * 10),
                            itemCount: sortedTasks.length,
                            itemBuilder: (context, index) {
                              final task = sortedTasks[index];
                              final originalIndex =
                                  task['originalIndex'] as int;
                              return Card(
                                color: Colors.grey.shade300,
                                elevation: buttonElevation,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    buttonBorderRadius,
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(
                                  vertical: spacingUnit,
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: task['isCompleted'],
                                    onChanged:
                                        (value) => _toggleTaskCompletion(
                                          originalIndex,
                                        ),
                                    activeColor: midColor,
                                    checkColor: vanilla,
                                  ),
                                  title: Text(
                                    task['title'],
                                    style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontSize: bodyFontSize,
                                      fontWeight: bodyFontWeight,
                                      color: getTextColor(vanilla),
                                      decoration:
                                          task['isCompleted']
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: midColor,
                                          size: iconSize,
                                        ),
                                        onPressed:
                                            () => _editTask(originalIndex),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: midColor,
                                          size: iconSize,
                                        ),
                                        onPressed:
                                            () => _deleteTask(originalIndex),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: spacingUnit * 2,
            right: spacingUnit * 2,
            child: FloatingActionButton(
              onPressed: _showAddTaskDialog,
              backgroundColor: midColor,
              foregroundColor: getTextColor(
                ProfileColorManager.getProfileColor(),
              ),
              elevation: buttonElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              child: Icon(Icons.add, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}

class Debouncer {
  final Duration duration;
  Timer? _timer;
  Debouncer({required this.duration});
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

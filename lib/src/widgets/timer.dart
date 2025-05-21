import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/platform_widget.dart';
import 'package:widgets_pack/src/utils/app_theme.dart';
import 'package:widgets_pack/src/utils/supabase_utils.dart';

class TimerWidget extends PlatformWidget {
  static const String _uuid = '018c3453-3862-7c38-96e7-6cf16e33d535';
  static const String _developerUuid = '11857a68-bc9a-41b1-9a54-e54b84af0a29';

  const TimerWidget({super.key});

  @override
  String get id => _uuid;
  @override
  String get name => 'Time Tracker';
  @override
  String get description =>
      """A timer to track your focus sessions! 🕑\nIt aims to help you focus on any task you are working on, such as study, writing, or coding.""";
  @override
  String get developerId => _developerUuid;

  @override
  Map<String, dynamic> get uiConfig => {
    'taskName': '',
    'hours': 1,
    'minutes': 20,
    'seconds': 0,
    'breakInterval': 20,
    'breakIntervalEnabled': true,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUserConfig(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return TimerWidgetContent(configuration: snapshot.data!, widgetId: id);
      },
    );
  }

  Future<Map<String, dynamic>> _loadUserConfig() async {
    try {
      final customConfig = await SupabaseUtils.loadUserConfiguration(id);

      return {
        'taskName': customConfig['taskName'] ?? uiConfig['taskName'],
        'hours': customConfig['hours'] ?? uiConfig['hours'],
        'minutes': customConfig['minutes'] ?? uiConfig['minutes'],
        'seconds': customConfig['seconds'] ?? uiConfig['seconds'],
        'breakInterval':
            customConfig['breakInterval'] ?? uiConfig['breakInterval'],
        'breakIntervalEnabled':
            customConfig['breakIntervalEnabled'] ??
            uiConfig['breakIntervalEnabled'],
      };
    } catch (e) {
      debugPrint('Error loading user custom configuration: $e');
      return uiConfig;
    }
  }
}

class TimerWidgetContent extends StatefulWidget {
  final Map<String, dynamic> configuration;
  final String widgetId;

  const TimerWidgetContent({
    super.key,
    required this.configuration,
    required this.widgetId,
  });

  @override
  State<TimerWidgetContent> createState() => _TimerWidgetContentState();
}

class _TimerWidgetContentState extends State<TimerWidgetContent> {
  late TextEditingController _taskNameController;
  late int _hours;
  late int _minutes;
  late int _seconds;
  late int _breakInterval;
  late bool _breakIntervalEnabled;
  bool _isTimerRunning = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isBreakTime = false;
  int _lastBreakMinute = -1;
  int _breakSeconds = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(
      text: widget.configuration['taskName'] ?? '',
    );
    _hours = widget.configuration['hours'] ?? 1;
    _minutes = widget.configuration['minutes'] ?? 20;
    _seconds = widget.configuration['seconds'] ?? 0;
    _breakInterval = widget.configuration['breakInterval'] ?? 0;
    _breakIntervalEnabled =
        widget.configuration['breakIntervalEnabled'] ?? false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    final updatedConfiguration = {
      'taskName': _taskNameController.text,
      'hours': _hours,
      'minutes': _minutes,
      'seconds': _seconds,
      'breakInterval': _breakInterval,
      'breakIntervalEnabled': _breakIntervalEnabled,
    };

    await SupabaseUtils.saveUserConfiguration(
      updatedConfiguration,
      TimerWidget().id,
    );
  }

  void _startTimer() {
    if (!mounted) return;

    setState(() {
      _isTimerRunning = true;
      _isBreakTime = false;
      _remainingSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;
      _lastBreakMinute = -1;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          _showCompletionDialog();
          return;
        }

        if (_breakIntervalEnabled) {
          final elapsedMinutes =
              ((_hours * 3600 + _minutes * 60 + _seconds - _remainingSeconds) /
                      60)
                  .floor();
          if (elapsedMinutes > 0 &&
              elapsedMinutes % _breakInterval == 0 &&
              elapsedMinutes != _lastBreakMinute &&
              !_isBreakTime) {
            _lastBreakMinute = elapsedMinutes;
            _timer?.cancel();
            _isTimerRunning = false;
            _showBreakPopup();
          }
        }
      });
    });
  }

  void _endSession() {
    if (!mounted) return;

    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isBreakTime = false;
      _remainingSeconds = 0;
    });
  }

  void _takeBreak() {
    if (!mounted) return;

    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _isBreakTime = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Taking a break...')));
  }

  void _continueTimer() {
    if (!mounted || _isNavigating) return;

    setState(() {
      _isTimerRunning = true;
      _isBreakTime = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          _showCompletionDialog();
          return;
        }

        if (_breakIntervalEnabled) {
          final elapsedMinutes =
              ((_hours * 3600 + _minutes * 60 + _seconds - _remainingSeconds) /
                      60)
                  .floor();
          if (elapsedMinutes > 0 &&
              elapsedMinutes % _breakInterval == 0 &&
              elapsedMinutes != _lastBreakMinute &&
              !_isBreakTime) {
            _lastBreakMinute = elapsedMinutes;
            _timer?.cancel();
            _isTimerRunning = false;
            _showBreakPopup();
          }
        }
      });
    });
  }

  void _showBreakPopup() {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Time for a Break!'),
          content: const Text(
            'You’ve been focused for a while. \nTake a 10-minute break to recharge?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  _isNavigating = false;
                  if (mounted) {
                    _continueTimer();
                  }
                });
              },
              child: const Text('Keep working'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  _isNavigating = false;
                  if (mounted) {
                    _startBreakTimer();
                  }
                });
              },
              child: const Text('Take a break'),
            ),
          ],
        );
      },
    ).then((_) {
      _isNavigating = false;
    });
  }

  void _startBreakTimer() {
    if (!mounted || _isNavigating) return;

    _breakSeconds = 10 * 60;
    Timer? breakTimer;
    bool isDialogOpen = true;

    _isNavigating = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!mounted || !isDialogOpen) {
                timer.cancel();
                return;
              }
              setDialogState(() {
                if (_breakSeconds > 0) {
                  _breakSeconds--;
                } else {
                  timer.cancel();
                  isDialogOpen = false;
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _isNavigating = false;
                    if (mounted) {
                      _continueTimer();
                    }
                  });
                }
              });
            });

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                breakTimer?.cancel();
                isDialogOpen = false;
                Future.delayed(const Duration(milliseconds: 300), () {
                  _isNavigating = false;
                  if (mounted) {
                    _continueTimer();
                  }
                });
              },
              child: AlertDialog(
                title: const Text('Break Time'),
                content: Text(
                  'Time remaining: ${_formatTime(_breakSeconds)}',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      breakTimer?.cancel();
                      isDialogOpen = false;
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _isNavigating = false;
                        if (mounted) {
                          _continueTimer();
                        }
                      });
                    },
                    child: const Text('End break early'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      breakTimer?.cancel();
      isDialogOpen = false;
      _isNavigating = false;
    });
  }

  void _showCompletionDialog() {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: const Text('Your focus session has ended. Well done!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  _isNavigating = false;
                  if (mounted) {
                    _endSession();
                  }
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      _isNavigating = false;
    });
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  void _showTimePicker(BuildContext context) {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.grey.shade300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: earth),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveConfiguration();
                      },
                      child: const Text('Done', style: TextStyle(color: earth)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: Duration(
                    hours: _hours,
                    minutes: _minutes,
                    seconds: _seconds,
                  ),
                  onTimerDurationChanged: (Duration duration) {
                    if (mounted) {
                      setState(() {
                        _hours = duration.inHours;
                        _minutes = duration.inMinutes % 60;
                        _seconds = duration.inSeconds % 60;
                      });
                    }
                  },
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

  void _showBreakIntervalPicker(BuildContext context) {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;
    int tempHours = _breakInterval ~/ 60;
    int tempMinutes = _breakInterval % 60;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.grey.shade300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromARGB(255, 103, 76, 76),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _breakInterval = (tempHours * 60) + tempMinutes;
                          if (_breakInterval <= 0) {
                            _breakInterval = 1;
                          }
                        });
                        Navigator.pop(context);
                        _saveConfiguration();
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Color.fromARGB(255, 9, 55, 11)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(
                    hours: tempHours,
                    minutes: tempMinutes,
                  ),
                  onTimerDurationChanged: (Duration duration) {
                    tempHours = duration.inHours;
                    tempMinutes = duration.inMinutes % 60;
                  },
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

  @override
  Widget build(BuildContext context) {
    if (_isTimerRunning || _isBreakTime) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Task: ${_taskNameController.text}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isBreakTime ? 'On break' : 'Work in progress',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(12, 61, 39, 39),
                    border: Border.all(
                      color:
                          Theme.of(context).scaffoldBackgroundColor == vanilla
                              ? aubergine
                              : vanilla,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Helvetica',
                        color:
                            Theme.of(context).scaffoldBackgroundColor == vanilla
                                ? aubergine
                                : vanilla,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!_isBreakTime && _remainingSeconds > 0) ...[
                      ElevatedButton(
                        onPressed: _takeBreak,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: earth,
                          backgroundColor: Colors.grey.shade400,
                          shadowColor: earth,
                          minimumSize: const Size(150, 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Take a break'),
                      ),
                    ],
                    if (_isBreakTime && _remainingSeconds > 0) ...[
                      ElevatedButton(
                        onPressed: _continueTimer,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: earth,
                          backgroundColor: Colors.grey.shade400,
                          shadowColor: earth,
                          minimumSize: const Size(150, 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Continue'),
                      ),
                    ],
                    ElevatedButton(
                      onPressed: _endSession,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: earth,
                        backgroundColor: Colors.grey.shade400,
                        shadowColor: earth,
                        minimumSize: const Size(150, 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('End session'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Task Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _taskNameController,
              cursorColor: getTextColor(
                Theme.of(context).scaffoldBackgroundColor,
              ),
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: bodyFontSize,
                fontWeight: bodyFontWeight,
                color: getTextColor(Theme.of(context).scaffoldBackgroundColor),
              ),
              decoration: InputDecoration(
                hintText: 'Enter task name here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) => _saveConfiguration(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Focusing time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showTimePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: spacingUnit * 2,
                  vertical: spacingUnit,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: midColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 18, color: midColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Get a break reminder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<bool>(
                  title: const Text('Never'),
                  value: false,
                  groupValue: _breakIntervalEnabled,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _breakIntervalEnabled = value;
                      });
                      _saveConfiguration();
                    }
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('Custom time'),
                  value: true,
                  groupValue: _breakIntervalEnabled,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _breakIntervalEnabled = value;
                      });
                      _saveConfiguration();
                    }
                  },
                ),
                if (_breakIntervalEnabled) ...[
                  GestureDetector(
                    onTap: () => _showBreakIntervalPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: midColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(_breakInterval ~/ 60).toString().padLeft(2, '0')}:${(_breakInterval % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: headerFontSize),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: midColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  foregroundColor: earth,
                  backgroundColor: Colors.grey.shade400,
                  shadowColor: earth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  minimumSize: const Size(200, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text(
                  'Start focus session',
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

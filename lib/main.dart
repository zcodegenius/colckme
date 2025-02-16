import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm Clock',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  Duration snoozeDuration = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _scheduleAlarm() async {
    final DateTime now = DateTime.now();
    final DateTime scheduledDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (scheduledDate.isAfter(now)) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'alarm_notif',
            'alarm_notif',
            channelDescription: 'Channel for Alarm notification',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.schedule(
        0,
        'Alarm',
        'It is time! Wake up!',
        scheduledDate,
        platformChannelSpecifics,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Clock')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: const Text('Select Date'),
              subtitle: Text('${selectedDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('Select Time'),
              subtitle: Text(selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            ListTile(
              title: const Text('Snooze Duration (minutes)'),
              subtitle: Text('${snoozeDuration.inMinutes} minutes'),
              trailing: const Icon(Icons.snooze),
              onTap: () async {
                final Duration? picked = await showDurationPicker(
                  context: context,
                  initialDuration: snoozeDuration,
                );
                if (picked != null && picked != snoozeDuration) {
                  setState(() {
                    snoozeDuration = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleAlarm,
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialDuration,
}) async {
  return showDialog<Duration>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Snooze Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[DurationPicker(initialDuration: initialDuration)],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(initialDuration);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

class DurationPicker extends StatefulWidget {
  const DurationPicker({Key? key, required this.initialDuration})
    : super(key: key);

  final Duration initialDuration;

  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late Duration duration;

  @override
  void initState() {
    super.initState();
    duration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NumberPicker(
          value: duration.inMinutes,
          minValue: 1,
          maxValue: 60,
          onChanged: (int value) {
            setState(() {
              duration = Duration(minutes: value);
            });
          },
        ),
      ],
    );
  }
}

class NumberPicker extends StatelessWidget {
  const NumberPicker({
    Key? key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  }) : super(key: key);

  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (value > minValue) {
              onChanged(value - 1);
            }
          },
        ),
        Text('$value'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (value < maxValue) {
              onChanged(value + 1);
            }
          },
        ),
      ],
    );
  }
}

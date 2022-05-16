import 'dart:convert';

import 'package:nobrainer/src/TodoPage/TodoItemDetails.dart';
import 'package:nobrainer/src/TodoPage/TodoNotifyScreen.dart';
import 'package:nobrainer/src/app.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TodoNotifier {
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  TodoNotifier() {
    _initNotificationPlugin();
    tz.initializeTimeZones();
  }

  _initNotificationPlugin() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);
    await _notificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<FlutterLocalNotificationsPlugin> _getNotificationPlugin() async {
    if (_notificationsPlugin == null) {
      await _initNotificationPlugin();
    }
    return _notificationsPlugin;
  }

  void _onSelectNotification(String? payload) async {
    if (payload != null) {
      Map todoItem = json.decode(payload);
      Navigator.of(NavKey.navigatorKey.currentContext!).push(
        MaterialPageRoute<void>(
          builder: (context) => TodoNotifyScreen(todoItem: todoItem),
        ),
      );
    }
  }

  scheduleNotification(Map todoItem) async {
    tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(DateTime.parse(todoItem["deadline"]), tz.local);

    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    FlutterLocalNotificationsPlugin plugin = await _getNotificationPlugin();
    await plugin.zonedSchedule(
      todoItem["id"].hashCode,
      todoItem["title"],
      todoItem["desc"],
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('todo', 'Todo Item Alarm',
            channelDescription: 'Do this item'),
      ),
      androidAllowWhileIdle: true,
      payload: json.encode(todoItem),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  unscheduleNotification(int id) async {
    FlutterLocalNotificationsPlugin plugin = await _getNotificationPlugin();
    await plugin.cancel(id);
  }
}

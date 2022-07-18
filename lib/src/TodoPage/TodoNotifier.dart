import 'dart:convert';

import 'package:nobrainer/src/TodoPage/TodoItem.dart';
import 'package:nobrainer/src/TodoPage/TodoNotifyScreen.dart';
import 'package:nobrainer/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart' as tz;

class TodoNotifier {
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  TodoNotifier() {
    _initNotificationPlugin();
    initializeTimeZones();
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
      Map      row  = json.decode(payload);
      TodoItem item = TodoItem.from(row);
      Navigator.of(NavKey.navigatorKey.currentContext!).push(
        MaterialPageRoute<void>(
          builder: (context) => TodoNotifyScreen(item: item),
        ),
      );
    }
  }

  scheduleNotification(TodoItem item) async {
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      item.deadline, tz.local,
    ).subtract(Duration(minutes: item.notifytime));
    tz.TZDateTime nowTime = tz.TZDateTime.now(tz.local);

    if (scheduledTime.isBefore(nowTime)) return;

    FlutterLocalNotificationsPlugin plugin =
      await _getNotificationPlugin();

    await plugin.zonedSchedule(
      "todo-${item.id}".hashCode,
      item.title,
      item.desc,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('todo', 'Todo Item Alarm',
            channelDescription: 'Do this item'),
      ),
      androidAllowWhileIdle: true,
      payload: json.encode(item.toMap()),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  unscheduleNotification(TodoItem item) async {
    FlutterLocalNotificationsPlugin plugin =
      await _getNotificationPlugin();

    await plugin.cancel(
      "todo-${item.id}".hashCode
    );
  }
}

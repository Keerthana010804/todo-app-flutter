import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'services/notification_service.dart';
import 'screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }
  
  if (defaultTargetPlatform == TargetPlatform.android) {
    await NotificationService.requestNotificationPermission();
    await NotificationService.requestExactAlarmPermission();
  }
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
  ));
}

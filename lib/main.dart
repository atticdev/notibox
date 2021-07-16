import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notibox/app/config/theme.dart';
import 'package:notibox/app/data/repository/settings_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/services/background_service.dart';
import 'app/services/notification_service.dart';
import 'package:background_fetch/background_fetch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hiveInit();
  notificationInit();
  await _firebaseInit();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(
    GetMaterialApp(
      title: "Notibox",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppThemes.lightTheme,
      builder: EasyLoading.init(),
      darkTheme: AppThemes.darkTheme,
      themeMode: SettingsRepository.isDarkMode() == null
          ? ThemeMode.system
          : SettingsRepository.isDarkMode()!
              ? ThemeMode.dark
              : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      enableLog: true,
    ),
  );
  easyLoadingConfig();
}

Future<void> _firebaseInit() async {
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

Future<void> hiveInit() async {
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('settings');
}

void easyLoadingConfig() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.black
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..animationDuration = Duration(milliseconds: 100)
    ..indicatorWidget = CircularProgressIndicator(
      color: Colors.white,
    );
}

import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notibox/app/data/model/inbox_model.dart';
import 'package:notibox/app/data/notion_provider.dart';
import 'package:notibox/app/modules/home/exceptions/home_exception.dart';
import 'package:notibox/app/modules/home/views/create_inbox_dialog.dart';
import 'package:notibox/app/modules/home/views/view_inbox_dialog.dart';

class HomeController extends GetxController {
  final _notionProvider = Get.put(NotionProvider());
  Rx<List<Inbox>> listInbox = Rx([]);
  Rx<String> errorMessage = ''.obs;
  Rx<bool> init = true.obs;
  Rx<bool> isOffline = false.obs;
  final indicator = GlobalKey<RefreshIndicatorState>();

  @override
  void onInit() {
    super.onInit();
    InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          isOffline.value = false;
          manualRefresh();
          break;
        case InternetConnectionStatus.disconnected:
          isOffline.value = true;
          break;
      }
    });
  }

  @override
  void onReady() async {
    super.onReady();
    indicator.currentState!.show();
    await getListInbox();
    init.value = false;
  }

  Future<void> createInbox() async {
    final res = await Get.dialog(CreateInboxDialog());
    // Refresh if the result was not null;
    if (res != null) {
      manualRefresh();
    }
  }

  Future<void> createReminder(List<Inbox> listInbox) async {
    AwesomeNotifications().cancelAllSchedules();

    // Create notification for each inbox (who has notification)
    listInbox.forEach((inbox) async {
      if (inbox.reminder != null && inbox.reminder!.isAfter(DateTime.now())) {
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: inbox.pageId!.hashCode,
              channelKey: 'reminder',
              title: inbox.title,
              body: inbox.description,

              autoCancel: true,
              createdLifeCycle: NotificationLifeCycle.Background,
            ),
            schedule: NotificationCalendar.fromDate(date: inbox.reminder!));
      }
    });
  }

  Future<void> viewInbox(Inbox inbox) async {
    final res = await Get.dialog(ViewInboxDialog(inbox));

    // Refresh  if the result was not null
    if (res != null) {
      manualRefresh();
    }
  }

  Future<void> manualRefresh() async {
    indicator.currentState!.show();
    await getListInbox();
  }

  bool isError() {
    return errorMessage.value != '';
  }

  bool isEmpty() {
    return listInbox.value.isEmpty;
  }

  Future<void> getListInbox() async {
    try {
      listInbox.value = await _notionProvider.getListInbox();

      // Add reminder
      await createReminder(listInbox.value);
      errorMessage.value = '';
    } on DioError catch (e) {
      errorMessage.value = HomeException.fromDioError(e).message;
    }
  }
}

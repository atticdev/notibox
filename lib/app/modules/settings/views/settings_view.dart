import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:notibox/app/data/repository/settings_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('API Integration Token'),
            subtitle: const Text('Your Notion internal integration token'),
            onTap: () async {
              final res = await Get.dialog(
                  alertDialog('API Token', controller.getToken())) as String;
              controller.updateToken(res);
            },
          ),
          ListTile(
            title: const Text('Database ID'),
            subtitle: Text(
              SettingsRepository.getDatabaseId()! as String,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              final res = await Get.dialog(
                      alertDialog('Database ID', controller.getDatabaseId()))
                  as String;
              controller.updateToken(res);
            },
          ),
          const Divider(),
          SwitchListTile(
              title: const Text('Dark Mode'),
              value: Get.isDarkMode,
              onChanged: (val) => controller.toggleDarkMode(isDarkMode: val)),
          const Divider(),
          ListTile(
            title: const Text('About'),
            onTap: () async {
              final PackageInfo packageInfo = await PackageInfo.fromPlatform();
              showAboutDialog(
                  context: context,
                  applicationVersion: packageInfo.version,
                  children: [
                    const Text(
                        'Notibox is an inbox application to store quick notes efficiently in Notion.')
                  ],
                  applicationIcon: Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(Get.isDarkMode
                          ? 'assets/logo/logo_dark.svg'
                          : 'assets/logo/logo_light.svg')));
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: controller.showPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}

Widget alertDialog(String title, String currentValue) {
  String result = '';
  final controller = TextEditingController(text: currentValue);
  final key = GlobalKey<FormState>();
  return Form(
    key: key,
    child: AlertDialog(
      title: Text('Edit $title'),
      content: TextFormField(
        decoration: InputDecoration(labelText: title),
        onChanged: (v) => result = v,
        controller: controller,
        maxLines: null,
        validator: (v) {
          if (v == null || v.isEmpty) {
            return '$title can not be empty';
          }
        },
      ),
      actions: [
        TextButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                Get.back(result: result);
              }
            },
            child: Text('Update'.toUpperCase()))
      ],
    ),
  );
}

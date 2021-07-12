
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:notibox/app/config/constants.dart';
import 'package:notibox/app/data/model/database_model.dart';
import 'package:notibox/app/data/model/inbox_model.dart';
import 'package:notibox/app/data/repository/settings_repository.dart';

class NotionProvider {
  final _dio = Get.put(Dio());

  Future<List<Database>> getListDatabase() async {
    final token = (await SettingsRepository.instance()).getToken();

    final res = await _dio.get(BASE_URL + 'databases',
        options: Options(headers: {
          'Authorization': 'Bearer ' + token!,
          'Notion-Version': NOTION_VERSION
        }));

    return (res.data['results'] as List)
        .map((e) => Database.fromMap(e))
        .toList();
  }

  Future<List<Inbox>> getListInbox() async {
    final token = (await SettingsRepository.instance()).getToken();
    final databaseId = (await SettingsRepository.instance()).getDatabaseId();
    final res = await Dio().post(BASE_URL + 'databases/$databaseId/query',
        options: Options(headers: {
          'Authorization': 'Bearer ' + token!,
          'Notion-Version': NOTION_VERSION
        }),
        data: {
          'sorts': [
            {'timestamp': 'created_time', 'direction': 'descending'}
          ]
        });
    return (res.data['results'] as List).map((e) => Inbox.fromMap(e)).toList();
  }

  Future createInbox({required Inbox inbox}) async {
    final token = (await SettingsRepository.instance()).getToken();
    final databaseId = (await SettingsRepository.instance()).getDatabaseId();
    await Dio().post(BASE_URL + 'pages',
        data: {
          'parent': {
            'database_id': databaseId!,
          },
          'properties': inbox.toMap()
        },
        options: Options(headers: {
          'Authorization': 'Bearer ' + token!,
          'Notion-Version': NOTION_VERSION
        }));
  }
}

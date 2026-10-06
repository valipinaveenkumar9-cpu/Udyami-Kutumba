import 'dart:io';

void main() {
  final file = File('d:/DigiNik/Apps/udyamikutumba/lib/core/api/taluka_api.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('}', '''  Future<dynamic> getAllUcnMembersUnderTaluka(String talukaId) async {
    return await _api.get('/talukas/getAllUcnMembersUnderTaluka/\');
  }\n}''');
  file.writeAsStringSync(content);
}

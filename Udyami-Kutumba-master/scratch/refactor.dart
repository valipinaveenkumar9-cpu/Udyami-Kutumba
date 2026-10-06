import 'dart:io';

void main() {
  final path = r'd:\DigiNik\Apps\udyamikutumba\lib\features\profile\presentation\profile_screen.dart';
  final file = File(path);
  var code = file.readAsStringSync();

  String removeFunction(String code, String name) {
    var idx = code.indexOf('Future<void> \$name() async {');
    if (idx == -1) return code;
    var depth = 0;
    var started = false;
    for (var i = idx; i < code.length; i++) {
      if (code[i] == '{') {
        depth++;
        started = true;
      } else if (code[i] == '}') {
        depth--;
        if (started && depth == 0) {
          return code.substring(0, idx) + code.substring(i + 1);
        }
      }
    }
    return code;
  }

  code = removeFunction(code, '_saveProfile');
  code = removeFunction(code, '_executeProfileSave');

  file.writeAsStringSync(code);
  print('Done!');
}

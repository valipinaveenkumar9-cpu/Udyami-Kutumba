import 'dart:io';

void main() {
  final path = r'd:\DigiNik\Apps\udyamikutumba\lib\features\profile\presentation\profile_screen.dart';
  final file = File(path);
  var code = file.readAsStringSync();

  final oldStr = 'if (existing.businessImages != null) bDetails["businessImages"] = existing.businessImages;';
  final newStr = 'if (_selectedBusinessImageFiles.isEmpty && existing.businessImages != null) bDetails["businessImages"] = existing.businessImages;';

  code = code.replaceAll(oldStr, newStr);

  file.writeAsStringSync(code);
  print('Done patching image upload bug!');
}

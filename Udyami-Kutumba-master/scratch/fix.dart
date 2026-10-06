import 'dart:io';

void main() {
  final path = 'lib/features/ward/presentation/ward_screen.dart';
  var text = File(path).readAsStringSync();

  // Fix the broken ones from the previous bad replacement
  text = text.replaceAllMapped(RegExp(r'\$\{\(([A-Za-z0-9_]*)\.elapsedMilliseconds'), (match) {
    return '\${(sw${match.group(1)}.elapsedMilliseconds';
  });
  
  // Fix totalSw which was skipped (since it didn't start with sw)
  text = text.replaceAllMapped(RegExp(r'\$\{totalSw\.elapsedMilliseconds\} ms'), (match) {
    return '\${(totalSw.elapsedMilliseconds / 1000).toStringAsFixed(2)}s';
  });

  File(path).writeAsStringSync(text);
}

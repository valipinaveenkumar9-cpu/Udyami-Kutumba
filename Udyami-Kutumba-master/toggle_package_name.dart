import 'dart:io';

const knownPackageNames = [
  'com.diginik.udyamikutumba',
  'com.udyamibharat.kutumba',
  'com.ub.kutumba',
];

const filesToUpdate = [
  'android/app/build.gradle.kts',
  'android/app/build.gradle',
  'ios/Runner.xcodeproj/project.pbxproj',
  'lib/features/geofence/presentation/geofence_screen.dart',
  'lib/features/ucn/ucnsubscreens/invite_to_ucn_screen.dart',
  'linux/CMakeLists.txt',
  'macos/Runner.xcodeproj/project.pbxproj',
  'macos/Runner/Configs/AppInfo.xcconfig',
];

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run toggle_package_name.dart <target_package_name>');
    print('Options:');
    print('  com.udyamibharat.kutumba (UB Play Console)');
    print('  com.ub.kutumba (Diginik Play Console)');
    exit(1);
  }

  final targetPackageName = args.first;
  if (!knownPackageNames.contains(targetPackageName)) {
    print('Warning: Target package name "$targetPackageName" is not in the known list. Proceeding anyway...');
  }

  String? currentPackageName;

  // Find current package name from build.gradle.kts
  final buildGradleFile = File('android/app/build.gradle.kts');
  if (buildGradleFile.existsSync()) {
    final content = buildGradleFile.readAsStringSync();
    for (final name in knownPackageNames) {
      if (content.contains(name)) {
        currentPackageName = name;
        break;
      }
    }
  }

  if (currentPackageName == null) {
    print('Could not determine current package name from android/app/build.gradle.kts.');
    exit(1);
  }

  print('Current package name: $currentPackageName');
  print('Target package name: $targetPackageName');

  if (currentPackageName == targetPackageName) {
    print('Already using $targetPackageName. Nothing to do.');
    exit(0);
  }

  // Update text files
  for (final filePath in filesToUpdate) {
    final file = File(filePath);
    if (file.existsSync()) {
      print('Updating $filePath');
      var content = file.readAsStringSync();
      content = content.replaceAll(currentPackageName, targetPackageName);
      file.writeAsStringSync(content);
    }
  }

  // Handle MainActivity.kt directory movement
  final oldDirPath = 'android/app/src/main/kotlin/' + currentPackageName.replaceAll('.', '/');
  final newDirPath = 'android/app/src/main/kotlin/' + targetPackageName.replaceAll('.', '/');

  final oldMainActivity = File('$oldDirPath/MainActivity.kt');
  final newMainActivityDir = Directory(newDirPath);

  if (oldMainActivity.existsSync()) {
    print('Moving MainActivity.kt to $newDirPath');
    if (!newMainActivityDir.existsSync()) {
      newMainActivityDir.createSync(recursive: true);
    }

    var ktContent = oldMainActivity.readAsStringSync();
    ktContent = ktContent.replaceAll('package $currentPackageName', 'package $targetPackageName');
    
    final newMainActivity = File('$newDirPath/MainActivity.kt');
    newMainActivity.writeAsStringSync(ktContent);

    // Delete old file
    oldMainActivity.deleteSync();
    
    // Attempt to clean up empty directories
    var currentDir = oldMainActivity.parent;
    final kotlinDir = Directory('android/app/src/main/kotlin').absolute;
    while (currentDir.absolute.path != kotlinDir.path && currentDir.existsSync()) {
      if (currentDir.listSync().isEmpty) {
        currentDir.deleteSync();
        currentDir = currentDir.parent;
      } else {
        break;
      }
    }
  } else {
    print('Warning: MainActivity.kt not found in $oldDirPath');
  }

  print('Package name successfully updated to $targetPackageName');
}

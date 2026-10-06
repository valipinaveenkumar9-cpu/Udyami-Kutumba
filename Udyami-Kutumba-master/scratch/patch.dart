import 'dart:io';

void main() {
  final file = File('lib/features/home/presentation/main_screen.dart');
  var text = file.readAsStringSync();

  final importStatement = "import '../../SoicalChannels/presentation/social_channels_screen.dart';";
  if (!text.contains(importStatement)) {
    text = text.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n$importStatement");
  }

  final menuItem = """                            _buildDrawerItem(
                              context,
                              icon: Icons.forum_rounded,
                              title: 'Social Channels',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SocialChannelsScreen(),
                                  ),
                                );
                              },
                            ),
""";

  if (!text.contains('Social Channels')) {
    final searchStr = '''const NewsScreen(),
                                  ),
                                );
                              },
                            ),
''';
    final index = text.indexOf(searchStr);
    if (index != -1) {
      final insertIndex = index + searchStr.length;
      text = text.substring(0, insertIndex) + menuItem + text.substring(insertIndex);
    }
  }

  file.writeAsStringSync(text);
}

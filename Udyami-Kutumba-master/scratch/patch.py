import sys

with open('lib/features/home/presentation/main_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import_statement = "import '../../SoicalChannels/presentation/social_channels_screen.dart';"
if import_statement not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_statement)

menu_item = """                            _buildDrawerItem(
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
"""

if 'Social Channels' not in text:
    index = text.find('const NewsScreen(),\n                                  ),\n                                );\n                              },\n                            ),')
    if index != -1:
        insert_index = index + len('const NewsScreen(),\n                                  ),\n                                );\n                              },\n                            ),\n')
        text = text[:insert_index] + menu_item + text[insert_index:]

with open('lib/features/home/presentation/main_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

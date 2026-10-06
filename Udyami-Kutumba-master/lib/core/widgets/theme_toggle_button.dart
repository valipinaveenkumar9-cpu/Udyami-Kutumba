import 'package:flutter/material.dart';
import '../providers/theme_providers.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Hidden because we enforce system theme
    return const SizedBox.shrink();
  }
}

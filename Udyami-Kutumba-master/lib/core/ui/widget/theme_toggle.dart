import 'package:flutter/material.dart';
import '../../providers/theme_providers.dart';


class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // Hidden because we enforce system theme
    return const SizedBox.shrink();
  }
}

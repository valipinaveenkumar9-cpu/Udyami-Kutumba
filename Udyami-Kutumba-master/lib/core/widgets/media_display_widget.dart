import 'dart:convert';
import 'package:flutter/material.dart';

class MediaDisplayWidget extends StatelessWidget {
  final String mediaUrl;
  final double height;
  final double width;

  const MediaDisplayWidget({
    super.key,
    required this.mediaUrl,
    this.height = 250,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrl.isEmpty) return const SizedBox();

    final isBase64 = mediaUrl.startsWith('data:');
    if (isBase64) {
      final commaIndex = mediaUrl.indexOf(',');
      final base64String = commaIndex != -1 ? mediaUrl.substring(commaIndex + 1) : mediaUrl;
      
      try {
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        );
      } catch (e) {
        return const SizedBox();
      }
    }

    return Image.network(
      mediaUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox(),
    );
  }
}

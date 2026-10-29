import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import 'app_network_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.size = 34,
  });

  final String imageUrl;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.highlightSoft,
        shape: BoxShape.circle,
        border: Border.all(color: palette.line),
      ),
      alignment: Alignment.center,
      child: imageUrl.isEmpty
          ? Text(
              initials,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.highlight,
                fontWeight: FontWeight.w800,
              ),
            )
          : AppNetworkImage(url: imageUrl),
    );
  }
}

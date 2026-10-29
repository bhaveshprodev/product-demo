import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheKey,
  });

  final String url;
  final BoxFit fit;
  final String? cacheKey;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (url.isEmpty) {
      return Container(
        color: palette.surfaceMuted,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 26,
          color: palette.muted.withValues(alpha: 0.7),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      cacheKey: cacheKey,
      fadeInDuration: const Duration(milliseconds: 280),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (context, url) => Container(
        color: palette.surfaceMuted,
        alignment: Alignment.center,
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.muted.withValues(alpha: 0.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: palette.surfaceMuted,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 26,
          color: palette.muted.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

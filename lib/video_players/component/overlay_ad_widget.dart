import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../model/overlay_ad.dart';
import '../../generated/assets.dart';
import '../../components/cached_image_widget.dart';
import '../../utils/colors.dart';

class OverlayAdWidget extends StatelessWidget {
  final OverlayAd overlayAd;
  final bool isFullScreen;

  const OverlayAdWidget({super.key, required this.overlayAd, this.isFullScreen = false});

  @override
  Widget build(BuildContext context) {
    final double adSize = isFullScreen ? 240 : 180;

    return Container(
      width: adSize,
      height: adSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 16, offset: Offset(0, 6), spreadRadius: 2),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (overlayAd.clickThroughUrl != null && overlayAd.clickThroughUrl!.isNotEmpty) {
            launchUrl(Uri.parse(overlayAd.clickThroughUrl!));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: overlayAd.imageUrl,
            width: adSize,
            height: adSize,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: adSize,
              height: adSize,
              decoration: BoxDecoration(color: secondaryTextColor, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: CachedImageWidget(url: Assets.iconsIcError, fit: BoxFit.contain, width: adSize * 0.3, height: adSize * 0.3),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: adSize,
              height: adSize,
              decoration: BoxDecoration(color: secondaryTextColor, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: CachedImageWidget(url: Assets.iconsIcError, fit: BoxFit.contain, width: adSize * 0.3, height: adSize * 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

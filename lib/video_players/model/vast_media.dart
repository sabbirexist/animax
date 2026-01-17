import 'overlay_ad.dart';

class VastMedia {
  final List<String> mediaUrls;
  final List<String> clickThroughUrls;
  final List<String> clickTrackingUrls;
  final int? skipDuration;
  final List<OverlayAd> overlayAds;

  VastMedia({
    required this.mediaUrls,
    required this.clickThroughUrls,
    required this.clickTrackingUrls,
    this.skipDuration,
    this.overlayAds = const [],
  });
}

class OverlayAd {
  final String imageUrl;
  final String? clickThroughUrl;
  final int startTime; // in seconds
  final int duration; // in seconds

  OverlayAd({
    required this.imageUrl,
    this.clickThroughUrl,
    required this.startTime,
    required this.duration,
  });

  /// Creates a copy of this OverlayAd but with the given fields replaced with the new values.
  OverlayAd copyWith({
    String? imageUrl,
    String? clickThroughUrl,
    int? startTime,
    int? duration,
  }) {
    return OverlayAd(
      imageUrl: imageUrl ?? this.imageUrl,
      clickThroughUrl: clickThroughUrl ?? this.clickThroughUrl,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }
}

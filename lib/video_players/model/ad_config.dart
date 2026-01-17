class AdConfig {
  final String url;
  final bool isSkippable;
  final int skipAfterSeconds;
  final String? clickThroughUrl;
  final String type; // 'image' or 'video', default to 'video'

  AdConfig({
    required this.url,
    this.isSkippable = false,
    this.skipAfterSeconds = 5,
    this.clickThroughUrl,
    this.type = 'video',
  });
}

// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/video_players/quality_list_component.dart';
import 'package:streamit_laravel/video_players/subtitle_list_component.dart';
import 'package:streamit_laravel/video_players/video_settings_dialog.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../components/device_not_supported_widget.dart';
import '../components/loader_widget.dart';
import '../main.dart';
import '../screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import '../utils/colors.dart';
import '../utils/common_base.dart';
import '../utils/constants.dart';
import 'component/ad_widgets.dart';
import 'component/overlay_ad_widget.dart';
import 'embedded_video/embedded_video_player.dart';
import 'model/video_model.dart';
import 'video_player_controller.dart';

class VideoPlayersComponent extends StatelessWidget {
  final VideoPlayerModel videoModel;
  final LiveShowModel? liveShowModel;
  final bool isTrailer;
  final bool isFromDownloads;
  final bool isLoading;

  final VoidCallback? onWatchNow;

  final VoidCallback? onWatchNextEpisode;

  final bool isComingSoon;

  const VideoPlayersComponent({
    super.key,
    required this.videoModel,
    this.isComingSoon = false,
    this.liveShowModel,
    this.isTrailer = true,
    this.isFromDownloads = false,
    this.isLoading = false,
    this.onWatchNow,
    this.onWatchNextEpisode,
  });

  bool get isLive => liveShowModel != null && liveShowModel!.id > 0;

  bool isVideoTypeYoutube(VideoPlayersController controller) =>
      isLive ? liveShowModel?.streamType == PlayerTypes.youtube.toLowerCase() : (controller.videoUrlType.toLowerCase() == PlayerTypes.youtube.toLowerCase());

  bool isVideoTypeX265(VideoPlayersController controller) => controller.videoUrlType.toLowerCase() == PlayerTypes.x265.toLowerCase();

  bool isVideoTypeOther(VideoPlayersController controller) => (controller.videoUrlType.toLowerCase() == PlayerTypes.url.toLowerCase() ||
      controller.videoUrlType.toLowerCase() == PlayerTypes.hls.toLowerCase() ||
      controller.videoUrlType.toLowerCase() == PlayerTypes.local.toLowerCase());

  bool isVimeo(VideoPlayersController controller) => (controller.videoUrlType.toLowerCase() == PlayerTypes.vimeo.toLowerCase() || videoModel.videoUrlInput.contains(PlayerTypes.vimeo));

  bool isWebView(VideoPlayersController controller) => isVimeo(controller) || (controller.videoUrlType.toLowerCase() == PlayerTypes.embedded.toLowerCase());

  bool showSkip(VideoPlayersController controller) => isTrailer
      ? (!isComingSoon && controller.isTrailer.value && !controller.playNextVideo.value && controller.isProgressBarVisible.value)
      : (controller.hasNextVideo.value && !controller.isBuffering.value && !isTrailer && controller.playNextVideo.value);

  String getVideoURLLink(VideoPlayersController controller) {
    String url = "";
    if (isLive) {
      url = controller.liveShowModel.posterTvImage;
    } else {
      if (videoModel.thumbnailImage.isNotEmpty) {
        url = videoModel.thumbnailImage;
      } else if (videoModel.posterTvImage.isNotEmpty) {
        url = videoModel.posterTvImage;
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        autoRemove: true,
        init: VideoPlayersController(
          isTrailer: isTrailer.obs,
          videoModel: videoModel.obs,
          liveShowModel: liveShowModel ?? LiveShowModel(),
          onVideoChange: onWatchNow,
          onWatchNextVideo: onWatchNextEpisode,
        ),
        builder: (controller) {
          // Calculate skip and watch now button visibility
          return Obx(
            () => SizedBox(
              width: Get.width,
              height: Get.height,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  if (!isSupportedDevice.value)
                    DeviceNotSupportedComponent(title: videoModel.name)
                  else ...<Widget>[
                    if (controller.isBuffering.value && !controller.isVideoPlaying.value && !controller.isResumingFromAd.value)
                      SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (getVideoURLLink(controller).isNotEmpty)
                              CachedImageWidget(
                                url: getVideoURLLink(controller),
                                fit: BoxFit.cover,
                                width: Get.width,
                                height: Get.height,
                              )
                            else
                              Container(
                                height: Get.height,
                                width: Get.width,
                                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                              ),
                            LoaderWidget(),
                          ],
                        ),
                      )
                    else if (!controller.isTrailer.value && isMoviePaid(requiredPlanLevel: videoModel.requiredPlanLevel))
                      SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: 0.3,
                              child: getVideoURLLink(controller).isNotEmpty
                                  ? Image.network(
                                      getVideoURLLink(controller),
                                      height: Get.height,
                                      width: Get.width,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.medium,
                                    )
                                  : Container(
                                      height: Get.height,
                                      width: Get.width,
                                      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                                    ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(locale.value.subscriptionRequired, style: boldTextStyle()),
                                Text(
                                  locale.value.pleaseSubscribeOrUpgrade,
                                  style: secondaryTextStyle(),
                                ),
                                Focus(
                                  onKeyEvent: (node, event) {
                                    if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                                      Get.back();
                                      return KeyEventResult.handled;
                                    }
                                    return KeyEventResult.ignored;
                                  },
                                  canRequestFocus: true,
                                  autofocus: true,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: appColorPrimary,
                                        border: focusBorder(true),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(locale.value.ok, style: primaryTextStyle()),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    else if (videoModel.movieAccess == MovieAccess.payPerView && videoModel.isPurchased == false && !controller.isTrailer.value)
                      SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: 0.3,
                              child: getVideoURLLink(controller).isNotEmpty
                                  ? Image.network(
                                      getVideoURLLink(controller),
                                      height: Get.height,
                                      width: Get.width,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.medium,
                                    )
                                  : Container(
                                      height: Get.height,
                                      width: Get.width,
                                      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                                    ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(locale.value.rentRequired, style: boldTextStyle()),
                                Text(
                                  locale.value.rentToWatch,
                                  style: secondaryTextStyle(),
                                ),
                                Focus(
                                  onKeyEvent: (node, event) {
                                    if (event is KeyDownEvent) {
                                      if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                                        Get.back();
                                        return KeyEventResult.handled;
                                      }
                                    }
                                    return KeyEventResult.ignored;
                                  },
                                  canRequestFocus: true,
                                  autofocus: true,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: appColorPrimary,
                                        border: focusBorder(true),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(locale.value.ok, style: primaryTextStyle()),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    else if (isWebView(controller) || isVideoTypeYoutube(controller) || isVideoTypeOther(controller) || isVideoTypeX265(controller) || (isLive && liveShowModel!.serverUrl.isNotEmpty))
                      Stack(
                        children: [
                          KeyboardListener(
                            focusNode: controller.videoFocusNode,
                            onKeyEvent: controller.handleVideoControls,
                            child: buildVideo(
                              controller,
                              context,
                            ),
                          ),
                          Positioned(
                            left: 32,
                            right: 32,
                            bottom: 68,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                controller.currentSubtitle.value,
                                textAlign: TextAlign.center,
                                style: primaryTextStyle(
                                  color: Colors.white,
                                  backgroundColor: Colors.black87,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 24,
                            child: Row(
                              spacing: 4,
                              children: [
                                Obx(
                                  () {
                                    if ((controller.isTrailer.value && isTrailer) && !isLive) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: boxDecorationDefault(
                                          borderRadius: BorderRadius.circular(4),
                                          color: btnColor,
                                        ),
                                        child: Text(
                                          locale.value.trailer,
                                          style: secondaryTextStyle(color: white),
                                        ),
                                      );
                                    } else {
                                      return const Offstage();
                                    }
                                  },
                                ),
                                if (videoModel.movieAccess == MovieAccess.payPerView)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: boxDecorationDefault(
                                      borderRadius: BorderRadius.circular(4),
                                      color: rentedColor,
                                    ),
                                    child: Row(
                                      spacing: 4,
                                      children: [
                                        const CachedImageWidget(
                                          url: Assets.iconsIcRent,
                                          height: 14,
                                          width: 14,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          videoModel.isPurchased ? locale.value.rented : locale.value.rent,
                                          style: secondaryTextStyle(color: white),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 150),
                              opacity: controller.isProgressBarVisible.value && controller.showSubtitleOptions.value ? 1 : 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.5),
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.all(16),
                                child: SubtitleListComponent(controller: controller),
                              ),
                            ),
                          ).visible(!isLive && !controller.isTrailer.value && !isFromDownloads),
                          Positioned.fill(
                            child: Obx(
                              () => AnimatedOpacity(
                                duration: Duration(milliseconds: 150),
                                opacity: controller.isProgressBarVisible.value && controller.showQualityOptions.value ? 1 : 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.5),
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: QualityListComponent(
                                    controller: controller,
                                  ),
                                ),
                              ),
                            ),
                          ).visible(!isLive && !controller.isTrailer.value && !isFromDownloads),

                          /// Overlay Ad Widget
                          Positioned(
                            bottom: 100,
                            right: 20,
                            child: Obx(
                              () {
                                final overlayAd = controller.currentOverlayAd.value;
                                return overlayAd != null ? OverlayAdWidget(overlayAd: overlayAd) : const SizedBox.shrink();
                              },
                            ),
                          ).visible(!isLive && !controller.isTrailer.value && !isFromDownloads),
                        ],
                      )
                    else
                      Container(
                        height: Get.height,
                        width: Get.width,
                        decoration: boxDecorationDefault(
                          color: appScreenBackgroundDark,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 34, color: white),
                            10.height,
                            Text(
                              locale.value.videoNotFound,
                              style: boldTextStyle(size: 16, color: white),
                            ),
                          ],
                        ),
                      ),
                  ],
                  Obx(
                    () => Align(
                      alignment: Alignment.center,
                      child: controller.isLoading.value ? LoaderWidget() : Offstage(),
                    ),
                  ),
                  _adView(controller)
                ],
              ),
            ),
          );
        });
  }

  Widget buildVideo(VideoPlayersController controller, BuildContext context) {
    return Obx(
      () {
        return Stack(
          key: controller.uniqueKey,
          children: [
            if (isWebView(controller))
              SizedBox(
                height: Get.height,
                width: Get.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WebViewContentWidget(
                      key: controller.uniqueKey,
                      videoController: controller,
                    ),

                    // Custom controls overlay
                    Positioned.fill(
                      child: Obx(
                        () => controller.isBuffering.value
                            ? Center(
                                child: LoaderWidget(
                                  loaderColor: appColorPrimary.withValues(alpha: 0.4),
                                ),
                              )
                            : Offstage(),
                      ),
                    ),
                    Positioned(
                      bottom: 48,
                      left: 8,
                      right: 8,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 150),
                        opacity: 1,
                        child: Row(
                          spacing: 120,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (showSkip(controller))
                              Focus(
                                focusNode: controller.skipNextVideoFocusNode,
                                onKeyEvent: (node, event) {
                                  controller.handleVideoControls(event);
                                  return KeyEventResult.handled;
                                },
                                child: TextButton(
                                  style: ButtonStyle(
                                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                    visualDensity: VisualDensity.compact,
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadiusGeometry.circular(22),
                                        side: BorderSide(color: controller.isSkipNextFocused.value ? appColorPrimary : Colors.white54),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (controller.isTrailer.value) {
                                      controller.onVideoChange?.call();
                                    } else if (!controller.isTrailer.value && controller.playNextVideo.value) {
                                      controller.onWatchNextVideo?.call();
                                    }
                                  },
                                  child: Text(
                                    controller.isTrailer.value ? locale.value.lblSkip : "Next Episode",
                                    style: primaryTextStyle(color: controller.isSkipNextFocused.value ? appColorPrimary : white),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isVideoTypeYoutube(controller))
              SizedBox(
                height: Get.height,
                width: Get.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    YoutubePlayer(
                      key: controller.uniqueKey,
                      showVideoProgressIndicator: false,
                      controller: controller.youtubePlayerController.value,
                      progressIndicatorColor: appColorPrimary,
                      width: Get.width,
                      thumbnail: getVideoURLLink(controller).isNotEmpty && !getVideoURLLink(controller).contains("/data/user")
                          ? CachedImageWidget(
                              url: getVideoURLLink(controller),
                              fit: BoxFit.cover,
                              width: Get.width,
                              height: 220,
                            )
                          : null,
                      aspectRatio: 16 / 9,
                      bottomActions: [],
                      topActions: [],
                      onReady: () {
                        controller.continueWatch();
                        controller.youtubePlayerController.value.play();
                        controller.isVideoPlaying(true);
                        Future.delayed(Duration(milliseconds: 500), () {
                          controller.listenVideoEvent();
                        });
                      },
                      onEnded: (metaData) {
                        if (!isTrailer) {
                          controller.storeViewCompleted();
                        }
                      },
                    ),
                    Positioned(
                      bottom: Get.height * 0.18,
                      left: 16,
                      right: 16,
                      child: Obx(
                        () => Row(
                          spacing: 120,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Focus(
                              autofocus: true,
                              canRequestFocus: true,
                              focusNode: controller.skipNextVideoFocusNode,
                              onFocusChange: (value) {
                                controller.isSkipNextFocused(value);
                              },
                              onKeyEvent: (node, event) {
                                controller.handleVideoControls(event);
                                return KeyEventResult.handled;
                              },
                              child: TextButton(
                                style: ButtonStyle(
                                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                  visualDensity: VisualDensity.compact,
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.circular(22),
                                      side: BorderSide(color: controller.isSkipNextFocused.value ? appColorPrimary : Colors.white54),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (controller.isTrailer.value) {
                                    controller.onVideoChange?.call();
                                  } else if (!controller.isTrailer.value && controller.playNextVideo.value) {
                                    controller.onWatchNextVideo?.call();
                                  }
                                },
                                child: Text(
                                  controller.isTrailer.value ? locale.value.lblSkip : "Next Episode",
                                  style: primaryTextStyle(color: controller.isSkipNextFocused.value ? appColorPrimary : white),
                                ).paddingSymmetric(horizontal: 16),
                              ),
                            )
                          ],
                        ).visible(showSkip(controller) && !controller.isLoading.value),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Obx(() {
                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 150),
                          opacity: !controller.isTrailer.value && controller.isProgressBarVisible.value && controller.isVideoPlaying.value ? 1 : 0,
                          child: CommonProgressBar(controller: controller),
                        );
                      }),
                    ),
                  ],
                ),
              )
            else if (isVideoTypeX265(controller))
              Theme(
                data: ThemeData(
                  brightness: Brightness.dark,
                  bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: appScreenBackgroundDark,
                  ),
                  primaryColor: Colors.white,
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white),
                    bodySmall: TextStyle(color: Colors.white),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Obx(
                    () => controller.podPlayerController.value.videoUrl?.isEmpty ?? false
                        ? Container(
                            width: Get.width,
                            decoration: boxDecorationDefault(
                              color: appScreenBackgroundDark,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 34, color: white),
                                10.height,
                                Text(
                                  locale.value.videoNotFound,
                                  style: boldTextStyle(size: 16, color: white),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              PodVideoPlayer(
                                key: controller.uniqueKey,
                                alwaysShowProgressBar: false,
                                matchFrameAspectRatioToVideo: true,
                                overlayBuilder: (options) => Offstage(),
                                hideFullScreenButton: true,
                                controller: controller.podPlayerController.value,
                                videoThumbnail: getVideoURLLink(controller).isNotEmpty && !getVideoURLLink(controller).contains("/data/user")
                                    ? DecorationImage(
                                        image: NetworkImage(getVideoURLLink(controller)),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.4),
                                          BlendMode.darken,
                                        ),
                                      )
                                    : null,
                                onVideoError: () {
                                  return Container(
                                    width: Get.width,
                                    decoration: boxDecorationDefault(
                                      color: appScreenBackgroundDark,
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline_rounded, size: 34, color: white),
                                        10.height,
                                        Text(
                                          locale.value.videoNotFound,
                                          style: boldTextStyle(size: 16, color: white),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onLoading: (context) {
                                  return LoaderWidget(
                                    loaderColor: appColorPrimary.withValues(alpha: 0.4),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: Get.height * 0.18,
                                left: 16,
                                right: 16,
                                child: Obx(
                                  () => Row(
                                    spacing: 120,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Focus(
                                        autofocus: true,
                                        canRequestFocus: true,
                                        focusNode: controller.skipNextVideoFocusNode,
                                        onFocusChange: (value) {
                                          controller.isSkipNextFocused(value);
                                        },
                                        onKeyEvent: (node, event) {
                                          controller.handleVideoControls(event);
                                          return KeyEventResult.handled;
                                        },
                                        child: TextButton(
                                          style: ButtonStyle(
                                            padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                            visualDensity: VisualDensity.compact,
                                            shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadiusGeometry.circular(22),
                                                side: BorderSide(color: controller.isSkipNextFocused.value ? appColorPrimary : Colors.white54),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (controller.isTrailer.value) {
                                              controller.onVideoChange?.call();
                                            } else if (!controller.isTrailer.value && controller.playNextVideo.value) {
                                              controller.onWatchNextVideo?.call();
                                            }
                                          },
                                          child: Text(
                                            isTrailer.validate() ? locale.value.lblSkip : "Next Episode",
                                            style: primaryTextStyle(color: controller.isSkipNextFocused.value ? appColorPrimary : white),
                                          ).paddingSymmetric(horizontal: 16),
                                        ),
                                      )
                                    ],
                                  ).visible(showSkip(controller) && !controller.isLoading.value),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Obx(
                                  () => AnimatedOpacity(
                                    duration: Duration(milliseconds: 150),
                                    opacity: !controller.isTrailer.value && controller.isProgressBarVisible.value && controller.isVideoPlaying.value ? 1 : 0,
                                    child: CommonProgressBar(controller: controller),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              )
            else if (isVideoTypeOther(controller))
              Theme(
                data: ThemeData(
                  brightness: Brightness.dark,
                  bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: appScreenBackgroundDark,
                  ),
                  primaryColor: Colors.white,
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white),
                    bodySmall: TextStyle(color: Colors.white),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Obx(
                    () => controller.podPlayerController.value.videoUrl?.isEmpty ?? false
                        ? Container(
                            width: Get.width,
                            decoration: boxDecorationDefault(
                              color: appScreenBackgroundDark,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 34, color: white),
                                10.height,
                                Text(
                                  locale.value.videoNotFound,
                                  style: boldTextStyle(size: 16, color: white),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              PodVideoPlayer(
                                key: controller.uniqueKey,
                                alwaysShowProgressBar: false,
                                matchFrameAspectRatioToVideo: true,
                                overlayBuilder: (options) => Offstage(),
                                hideFullScreenButton: true,
                                controller: controller.podPlayerController.value,
                                videoThumbnail: getVideoURLLink(controller).isNotEmpty && !getVideoURLLink(controller).contains("/data/user")
                                    ? DecorationImage(
                                        image: NetworkImage(getVideoURLLink(controller)),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.4),
                                          BlendMode.darken,
                                        ),
                                      )
                                    : null,
                                onVideoError: () {
                                  return Container(
                                    width: Get.width,
                                    decoration: boxDecorationDefault(
                                      color: appScreenBackgroundDark,
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline_rounded, size: 34, color: white),
                                        10.height,
                                        Text(
                                          locale.value.videoNotFound,
                                          style: boldTextStyle(size: 16, color: white),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onLoading: (context) {
                                  return LoaderWidget(
                                    loaderColor: appColorPrimary.withValues(alpha: 0.4),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: Get.height * 0.18,
                                left: 16,
                                right: 16,
                                child: Obx(
                                  () => Row(
                                    spacing: 120,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Focus(
                                        autofocus: true,
                                        canRequestFocus: true,
                                        focusNode: controller.skipNextVideoFocusNode,
                                        onFocusChange: (value) {
                                          controller.isSkipNextFocused(value);
                                        },
                                        onKeyEvent: (node, event) {
                                          controller.handleVideoControls(event);
                                          return KeyEventResult.handled;
                                        },
                                        child: TextButton(
                                          style: ButtonStyle(
                                            padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                            visualDensity: VisualDensity.compact,
                                            shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadiusGeometry.circular(22),
                                                side: BorderSide(color: controller.isSkipNextFocused.value ? appColorPrimary : Colors.white54),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (controller.isTrailer.value) {
                                              controller.onVideoChange?.call();
                                            } else if (!controller.isTrailer.value && controller.playNextVideo.value) {
                                              controller.onWatchNextVideo?.call();
                                            }
                                          },
                                          child: Text(
                                            isTrailer.validate() ? locale.value.lblSkip : "Next Episode",
                                            style: primaryTextStyle(color: controller.isSkipNextFocused.value ? appColorPrimary : white),
                                          ).paddingSymmetric(horizontal: 16),
                                        ),
                                      )
                                    ],
                                  ).visible(showSkip(controller) && !controller.isLoading.value),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Obx(
                                  () => AnimatedOpacity(
                                    duration: Duration(milliseconds: 150),
                                    opacity: !controller.isTrailer.value && controller.isProgressBarVisible.value && controller.isVideoPlaying.value ? 1 : 0,
                                    child: CommonProgressBar(controller: controller),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              )
            else
              Container(
                width: Get.width,
                decoration: boxDecorationDefault(
                  color: appScreenBackgroundDark,
                ),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 34, color: white),
                    10.height,
                    Text(
                      locale.value.videoNotFound,
                      style: boldTextStyle(size: 16, color: white),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _adView(VideoPlayersController controller) {
    return AdView(
      controller: controller,
      skipInText: (seconds) => locale.value.skipIn(seconds),
      advertisementText: locale.value.advertisement,
      skipLabel: locale.value.lblSkip,
    );
  }
}

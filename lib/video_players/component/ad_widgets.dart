import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/video_players/video_player_controller.dart';
import '../ad_video_player.dart';
import '../../utils/colors.dart';
import '../component/custom_progress_bar.dart';

class AdView extends StatelessWidget {
  final VideoPlayersController controller;
  final String Function(int) skipInText;
  final String advertisementText;
  final String skipLabel;

  const AdView({
    super.key,
    required this.controller,
    required this.skipInText,
    required this.advertisementText,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isAdPlaying.value) {
        return SizedBox.shrink();
      }
      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final ad = controller.preRollAds.isNotEmpty &&
                      controller.currentAdIndex.value <
                          controller.preRollAds.length
                  ? controller.preRollAds[controller.currentAdIndex.value]
                  : null;
              final clickUrl = ad?.clickThroughUrl;
              if (clickUrl != null && clickUrl.isNotEmpty) {
                await launchUrl(Uri.parse(clickUrl));
              }
            },
            child: ADVideoPlayerWidget(
              key: controller.adViewPlayerKey,
              videoUrl: controller.adVideoUrl.value,
              listener: controller.adPlayerListener,
            ),
          ),
          if (controller.isAdPlaying.value && !isPipModeOn.value) ...[
            AdProgressBar(controller: controller),
          ],
          if (controller.isCurrentAdSkippable.value && !isPipModeOn.value) ...[
            Positioned(
              top: 10,
              right: 10,
              child: Obx(
                () => Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                    border: controller.adSkipTimer.value <= 0
                        ? Border.all(
                            color: controller.isSkipAdFocused.value
                                ? appColorPrimary
                                : Colors.transparent,
                            width: 2,
                          )
                        : null,
                  ),
                  child: controller.adSkipTimer.value > 0
                      ? Text(
                          skipInText(controller.adSkipTimer.value),
                          style: TextStyle(color: Colors.white),
                        )
                      : Focus(
                          focusNode: controller.skipAdFocusNode,
                          onFocusChange: (value) {
                            controller.isSkipAdFocused(value);
                          },
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey ==
                                      LogicalKeyboardKey.select ||
                                  event.logicalKey ==
                                      LogicalKeyboardKey.enter) {
                                controller.skipAd();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: InkWell(
                            onTap: controller.skipAd,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                skipLabel,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
          if (!isPipModeOn.value)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  advertisementText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class AdProgressBar extends StatelessWidget {
  final VideoPlayersController controller;

  const AdProgressBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 6,
      child: StreamBuilder<Duration>(
        stream: controller.adViewPlayerKey.currentState?.positionStream,
        builder: (context, snapshot) {
          final adPosition = snapshot.data ?? Duration.zero;
          final adDuration =
              controller.adViewPlayerKey.currentState?.totalDuration ??
                  Duration.zero;
          return StreamBuilder<bool>(
            stream: controller.adViewPlayerKey.currentState?.playingStream,
            builder: (context, playingSnapshot) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomProgressBar(
                  position: adPosition,
                  duration: adDuration,
                  adBreaks: [],
                  isAdPlaying: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

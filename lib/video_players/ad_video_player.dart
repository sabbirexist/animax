import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_laravel/components/loader_widget.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/empty_error_state_widget.dart';
import 'package:streamit_laravel/utils/extension/string_extention.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ADVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final Function()? listener;

  const ADVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
    this.listener,
  });

  @override
  State<ADVideoPlayerWidget> createState() => ADVideoPlayerWidgetState();
}

class ADVideoPlayerWidgetState extends State<ADVideoPlayerWidget> {
  YoutubePlayerController? _youtubeController;
  PodPlayerController? _podController;

  bool get isYoutube => widget.videoUrl.contains('youtube.com') || widget.videoUrl.contains('youtu.be');

  Timer? _ticker;
  final _positionController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<bool> get playingStream => _playingController.stream;

  Duration get currentPosition {
    if (isYoutube) {
      return _youtubeController?.value.position ?? Duration.zero;
    } else {
      return _podController?.currentVideoPosition ?? Duration.zero;
    }
  }

  Duration get totalDuration {
    if (isYoutube) {
      return _youtubeController?.value.metaData.duration ?? Duration.zero;
    } else {
      return _podController?.totalVideoLength ?? Duration.zero;
    }
  }

  @override
  void initState() {
    super.initState();
    if (isYoutube) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.videoUrl.getYouTubeId(),
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          enableCaption: false,
          hideControls: true,
        ),
      );
    } else {
      _podController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(widget.videoUrl),
        podPlayerConfig: const PodPlayerConfig(autoPlay: true),
      );
      _podController!.initialise();
    }
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant ADVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      if (isYoutube) {
        _youtubeController?.load(widget.videoUrl.getYouTubeId());
      } else {
        _podController?.changeVideo(
          playVideoFrom: PlayVideoFrom.network(widget.videoUrl),
        );
      }
    }
  }

  //Stream listeners
  void addListeners() {
    if (widget.listener == null) return;
    if (isYoutube) {
      _youtubeController?.addListener(widget.listener!);
    } else {
      _podController?.addListener(widget.listener!);
    }
  }

  void removeListeners() {
    if (widget.listener == null) return;
    if (isYoutube) {
      _youtubeController?.removeListener(widget.listener!);
    } else {
      _podController?.removeListener(widget.listener!);
    }
  }

  void pause() {
    if (isYoutube) {
      _youtubeController?.pause();
    } else {
      _podController?.pause();
    }
  }

  void play() {
    if (isYoutube) {
      _youtubeController?.play();
    } else {
      _podController?.play();
    }
  }

  void togglePlayPause() {
    if (isYoutube) {
      if (_youtubeController?.value.isPlaying == true) {
        _youtubeController?.pause();
      } else {
        _youtubeController?.play();
      }
    } else {
      if (_podController?.isVideoPlaying == true) {
        _podController?.pause();
      } else {
        _podController?.play();
      }
    }
  }

  //Ended
  bool get isEnded {
    if (isYoutube) {
      return _youtubeController?.value.playerState == PlayerState.ended;
    } else {
      return _podController?.videoPlayerValue?.isCompleted ?? false;
    }
  }

  bool get isPlaying {
    if (isYoutube) {
      return _youtubeController?.value.isPlaying ?? false;
    } else {
      return _podController?.isVideoPlaying ?? false;
    }
  }

  void mute() {
    if (isYoutube) {
      _youtubeController?.mute();
    } else {
      _podController?.mute();
    }
  }

  void unmute() {
    if (isYoutube) {
      _youtubeController?.unMute();
    } else {
      _podController?.unMute();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      try {
        _positionController.add(currentPosition);
        _playingController.add(isPlaying);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _positionController.close();
    _playingController.close();
    _youtubeController?.dispose();
    _podController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      child: isYoutube
          ? YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: false,
              progressIndicatorColor: appColorPrimary,
              width: Get.width,
              aspectRatio: widget.aspectRatio,
              bottomActions: [],
              topActions: [],
            )
          : PodVideoPlayer(
              controller: _podController!,
              videoAspectRatio: widget.aspectRatio,
              matchFrameAspectRatioToVideo: true,
              matchVideoAspectRatioToFrame: true,
              overlayBuilder: (options) => const Offstage(),
              alwaysShowProgressBar: false,
              hideFullScreenButton: true,
              onLoading: (context) {
                return LoaderWidget(
                  loaderColor: appColorPrimary.withValues(alpha: 0.4),
                );
              },
              onVideoError: () {
                return ErrorStateWidget();
              },
            ),
    );
  }
}

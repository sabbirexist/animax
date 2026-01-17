import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'custom_progress_bar.dart';

class CustomPodPlayerControlOverlay extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final List<Duration> adBreaks;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback? onReplay10;
  final VoidCallback? onForward10;
  final VoidCallback? onFullscreenToggle;
  final Widget? overlayAd;

  const CustomPodPlayerControlOverlay({
    super.key,
    required this.position,
    required this.duration,
    required this.adBreaks,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeek,
    this.onReplay10,
    this.onForward10,
    this.onFullscreenToggle,
    this.overlayAd,
  });

  @override
  State<CustomPodPlayerControlOverlay> createState() => _CustomPodPlayerControlOverlayState();
}

class _CustomPodPlayerControlOverlayState extends State<CustomPodPlayerControlOverlay> {
  bool isVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        isVisible = false;
      });
    });
  }

  void _onUserInteraction() {
    setState(() {
      isVisible = true;
    });
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _onUserInteraction();
          },
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () {
                        widget.onReplay10?.call();
                        _onUserInteraction();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        widget.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        widget.onPlayPause();
                        _onUserInteraction();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      onPressed: () {
                        widget.onForward10?.call();
                        _onUserInteraction();
                      },
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomProgressBar(
                        position: widget.position,
                        duration: widget.duration,
                        adBreaks: widget.adBreaks,
                        isAdPlaying: false,
                        onSeek: (duration) {
                          widget.onSeek(duration);
                          _onUserInteraction();
                        },
                      ).expand(),
                      Text(
                        '${formatDuration(widget.position)} / ${formatDuration(widget.duration)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.fullscreen, size: 20),
                        onPressed: () {
                          widget.onFullscreenToggle?.call();
                          _onUserInteraction();
                        },
                        tooltip: 'Fullscreen',
                      ),
                    ],
                  ),
                ),
              
              ],
            ),
          ),
        ),
        widget.overlayAd ?? const SizedBox.shrink(),
      ],
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

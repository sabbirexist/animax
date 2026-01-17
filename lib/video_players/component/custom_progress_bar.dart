import 'package:flutter/material.dart';
import 'package:streamit_laravel/utils/colors.dart';

class CustomProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final List<Duration> adBreaks; // seconds
  final bool isAdPlaying;
  final void Function(Duration)? onSeek;

  const CustomProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.adBreaks,
    this.isAdPlaying = false,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = duration.inSeconds == 0 ? 0 : position.inSeconds / duration.inSeconds;
    final barColor = appColorPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbWidth = 8.0;
        final actualBarWidth = constraints.maxWidth - thumbWidth;

        void handleSeek(Offset localPosition) {
          final dx = localPosition.dx - thumbWidth / 2;
          final percent = (dx / actualBarWidth).clamp(0.0, 1.0);
          final newSeconds = (duration.inSeconds * percent).round();
          if (onSeek != null) {
            onSeek!(Duration(seconds: newSeconds));
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            handleSeek(localPosition);
          },
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            handleSeek(localPosition);
          },
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                // Background bar
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    color: borderColorDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Thumb (round circle)
                if (!isAdPlaying)
                  Positioned(
                    left: (progress.clamp(0.0, 1.0) * actualBarWidth) - 4,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: barColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                ...adBreaks.where((adBreak) => adBreak > Duration.zero && adBreak < duration).map((adBreak) {
                  if (duration.inMilliseconds == 0) return const SizedBox();

                  final adPosition = adBreak.inMilliseconds / duration.inMilliseconds;
                  final clamped = adPosition.clamp(0.0, 1.0);
                  final left = clamped * actualBarWidth;

                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
                // Played progress
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

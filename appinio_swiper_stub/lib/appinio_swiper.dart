library appinio_swiper;

import 'dart:async';

import 'package:flutter/material.dart';

typedef AppinioSwiperCardBuilder =
    Widget Function(BuildContext context, int index);

class AppinioSwiperController {
  void Function(AxisDirection direction)? _onSwipe;

  void _attach(void Function(AxisDirection direction) handler) {
    _onSwipe = handler;
  }

  void swipeLeft() => _onSwipe?.call(AxisDirection.left);

  void swipeRight() => _onSwipe?.call(AxisDirection.right);
}

class SwipeOptions {
  final bool left;
  final bool right;

  const SwipeOptions.only({required this.left, required this.right});
}

class SwipeActivity {
  const SwipeActivity({required this.direction});

  final AxisDirection direction;
}

class AppinioSwiper extends StatefulWidget {
  const AppinioSwiper({
    super.key,
    required this.cardCount,
    required this.cardBuilder,
    this.controller,
    this.swipeOptions,
    this.onSwipeEnd,
    this.onEnd,
  });

  final int cardCount;
  final AppinioSwiperController? controller;
  final SwipeOptions? swipeOptions;
  final AppinioSwiperCardBuilder cardBuilder;
  final void Function(int previousIndex, int nextIndex, SwipeActivity activity)?
  onSwipeEnd;
  final FutureOr<void> Function()? onEnd;

  @override
  State<AppinioSwiper> createState() => _AppinioSwiperState();
}

class _AppinioSwiperState extends State<AppinioSwiper> {
  int _currentIndex = 0;

  SwipeOptions get _options =>
      widget.swipeOptions ?? const SwipeOptions.only(left: true, right: true);

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(_handleControllerSwipe);
  }

  @override
  void dispose() {
    widget.controller?._attach((_) {});
    super.dispose();
  }

  void _handleControllerSwipe(AxisDirection direction) {
    _performSwipe(direction);
  }

  void _performSwipe(AxisDirection direction) {
    if (_currentIndex >= widget.cardCount) return;
    final previous = _currentIndex;
    final nextIndex = _currentIndex + 1;
    widget.onSwipeEnd?.call(
      previous,
      nextIndex,
      SwipeActivity(direction: direction),
    );
    if (nextIndex >= widget.cardCount) {
      widget.onEnd?.call();
      return;
    }
    setState(() => _currentIndex = nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.cardCount > 0
        ? widget.cardBuilder(context, _currentIndex)
        : const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          bottom: 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_options.left)
                ElevatedButton(
                  onPressed: () => _performSwipe(AxisDirection.left),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Left'),
                )
              else
                const SizedBox(width: 64),
              if (_options.right)
                ElevatedButton(
                  onPressed: () => _performSwipe(AxisDirection.right),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Right'),
                )
              else
                const SizedBox(width: 64),
            ],
          ),
        ),
      ],
    );
  }
}

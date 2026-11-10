import 'package:flutter/material.dart';

/// Keeps a new task's content hidden until its exposure reservation is durable.
/// The parent owns the existing progress store and records the reservation;
/// this widget owns no storage, grades, XP, clock, or learner eligibility.
class Act0ContentPresentationGateV1 extends StatefulWidget {
  const Act0ContentPresentationGateV1({
    super.key,
    required this.presentationKey,
    required this.reserveExposure,
    required this.child,
    required this.onExit,
  });

  final String presentationKey;
  final Future<bool> Function() reserveExposure;
  final Widget child;
  final VoidCallback onExit;

  @override
  State<Act0ContentPresentationGateV1> createState() =>
      _Act0ContentPresentationGateV1State();
}

class _Act0ContentPresentationGateV1State
    extends State<Act0ContentPresentationGateV1> {
  int _generation = 0;
  bool _pending = true;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    _reserve();
  }

  @override
  void didUpdateWidget(Act0ContentPresentationGateV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presentationKey != widget.presentationKey) _reserve();
  }

  Future<void> _reserve() async {
    final generation = ++_generation;
    _pending = true;
    _acknowledged = false;
    bool acknowledged;
    try {
      acknowledged = await widget.reserveExposure();
    } catch (_) {
      acknowledged = false;
    }
    if (!mounted || generation != _generation) return;
    setState(() {
      _pending = false;
      _acknowledged = acknowledged;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_acknowledged) return widget.child;
    return Center(
      key: const Key('act0_content_presentation_gate'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pending) const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _pending
                  ? 'Saving your place before this check…'
                  : 'This check could not be saved safely. Your task is still hidden.',
            ),
            if (!_pending)
              TextButton(
                key: const Key('act0_content_presentation_retry'),
                onPressed: () {
                  setState(() {
                    _pending = true;
                  });
                  _reserve();
                },
                child: const Text('Try again'),
              ),
            TextButton(
              key: const Key('act0_content_presentation_exit'),
              onPressed: () {
                // Invalidate the pending callback even if navigation is delayed
                // or a parent route guard declines the exit.
                _generation++;
                setState(() {
                  _pending = false;
                });
                widget.onExit();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_growth_links_v1.dart';

const act0GrowthChannelV1 = MethodChannel('com.clubboss.sharky/growth_v1');

bool get act0GrowthSupportedV1 =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class Act0ShareLessonResultButtonV1 extends StatelessWidget {
  const Act0ShareLessonResultButtonV1({super.key});

  // A fixed payload keeps names, answers and private history out of the share.
  static const _text =
      'I completed a poker lesson in Sharky.\n$act0GrowthLearnLinkV1';

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Share lesson result'),
            content: const Text(_text),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Share'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize || box.size.isEmpty) return;
        try {
          await Share.share(
            _text,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
        } on PlatformException {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sharing is unavailable right now.')),
          );
        }
      },
      child: const Text('Share result'),
    );
  }
}

class Act0StoreReviewV1 {
  static const _lastRequestKey = 'act0.store_review.last_request.v1';
  static const cooldown = Duration(days: 180);
  bool _checking = false;

  Future<void> requestAfterMilestone({
    required DateTime now,
    required bool Function() canPresent,
  }) async {
    if (_checking || !canPresent()) return;
    _checking = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      final lastRequest = preferences.getInt(_lastRequestKey);
      if (lastRequest != null &&
          now.millisecondsSinceEpoch - lastRequest < cooldown.inMilliseconds) {
        return;
      }
      if (!canPresent()) return;
      // Reserve the attempt even when StoreKit suppresses or dismisses it.
      final reserved = await preferences.setInt(
        _lastRequestKey,
        now.millisecondsSinceEpoch,
      );
      if (reserved && canPresent()) {
        await act0GrowthChannelV1.invokeMethod<void>('requestReview');
      }
    } catch (_) {
      // A failed preference write or unavailable store cannot block learning.
    } finally {
      _checking = false;
    }
  }
}

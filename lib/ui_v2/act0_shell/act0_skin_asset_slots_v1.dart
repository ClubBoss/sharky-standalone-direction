import 'package:flutter/widgets.dart';

enum Act0SkinAssetSlotV1 {
  appIcon,
  sharkyNeutral,
  sharkyHappy,
  sharkyThinking,
  sharkyConcerned,
}

/// Flat, optional asset paths reserved for the V7 designer handoff.
const Map<Act0SkinAssetSlotV1, String> act0SkinAssetSlotsV1 = {
  Act0SkinAssetSlotV1.appIcon: 'assets/skin_v1/app_icon.png',
  Act0SkinAssetSlotV1.sharkyNeutral: 'assets/skin_v1/sharky_neutral.png',
  Act0SkinAssetSlotV1.sharkyHappy: 'assets/skin_v1/sharky_happy.png',
  Act0SkinAssetSlotV1.sharkyThinking: 'assets/skin_v1/sharky_thinking.png',
  Act0SkinAssetSlotV1.sharkyConcerned: 'assets/skin_v1/sharky_concerned.png',
};

/// Resolves an optional bundled image without introducing a new visual style.
///
/// The caller supplies its existing visual as [fallback] and owns the layout
/// constraints. Missing or unreadable artwork leaves that visual in place.
Widget resolveAct0SkinAssetV1(
  Act0SkinAssetSlotV1 slot, {
  required Widget fallback,
}) {
  return Image.asset(
    act0SkinAssetSlotsV1[slot]!,
    scale: 1,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) => fallback,
  );
}

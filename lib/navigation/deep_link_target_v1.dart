enum DeepLinkTargetV1 { phase1 }

DeepLinkTargetV1? parseDeepLinkTargetV1(String raw) {
  final token = raw.trim().toLowerCase();
  if (token.isEmpty) return null;
  switch (token) {
    case 'phase1':
      return DeepLinkTargetV1.phase1;
    default:
      return null;
  }
}

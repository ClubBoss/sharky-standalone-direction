class VisualIdentityV4QAScanner {
  const VisualIdentityV4QAScanner({
    required this.scanKernel,
    required this.scanTokens,
    required this.scanBinder,
  });

  final bool scanKernel;
  final bool scanTokens;
  final bool scanBinder;

  Map<String, String> run() {
    // TODO Phase-7 QA scanner logic
    return {
      'kernel': scanKernel ? 'pending' : 'skip',
      'tokens': scanTokens ? 'pending' : 'skip',
      'binder': scanBinder ? 'pending' : 'skip',
    };
  }
}

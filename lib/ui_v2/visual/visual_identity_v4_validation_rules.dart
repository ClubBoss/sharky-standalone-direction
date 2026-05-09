import 'visual_identity_v4_evaluation_context.dart';
import 'visual_identity_v4_validation_ledger.dart';

class V4IdentityValidationRules {
  const V4IdentityValidationRules();

  void writePending(V4IdentityValidationLedger ledger) {
    ledger.setEntry('rule.surface.mapping', 'pending');
    ledger.setEntry('rule.role.resolution', 'pending');
    ledger.setEntry('rule.descriptor.hydration', 'pending');
    ledger.setEntry('rule.visual.chain', 'pending');
    ledger.setEntry('rule.preflight.bundle', 'pending');
  }

  void evaluateBasic(
    V4IdentityEvaluationContext ctx,
    V4IdentityValidationLedger ledger,
  ) {
    ledger.setEntry(
      'rule.surface.mapping',
      ctx.surfaceTier != null ? 'ok' : 'missing',
    );
    ledger.setEntry(
      'rule.role.resolution',
      ctx.roleResolution != null ? 'ok' : 'missing',
    );
    ledger.setEntry(
      'rule.descriptor.hydration',
      ctx.hydratedDescriptor != null ? 'ok' : 'missing',
    );
    final chain = ctx.chainStatus;
    ledger.setEntry(
      'rule.visual.chain',
      chain != null && chain.isNotEmpty ? 'ok' : 'missing',
    );
    ledger.setEntry(
      'rule.preflight.bundle',
      ctx.preflightBundle != null ? 'ok' : 'missing',
    );
  }

  void evaluatePreflight(
    Map<String, dynamic>? preflightBundle,
    V4IdentityValidationLedger ledger,
  ) {
    if (preflightBundle == null) {
      ledger.setEntry('rule.preflight.present', 'missing');
      return;
    }
    ledger.setEntry('rule.preflight.present', 'ok');
    for (final key in preflightBundle.keys) {
      ledger.setEntry('rule.preflight.$key', 'ok');
    }
  }

  void reconcileChain(
    Map<String, dynamic>? chainStatus,
    Map<String, dynamic>? completeness,
    Map<String, dynamic>? evaluator,
    V4IdentityValidationLedger ledger,
  ) {
    if (chainStatus == null) {
      ledger.setEntry('rule.chain.present', 'missing');
    } else {
      ledger.setEntry('rule.chain.present', 'ok');
      chainStatus.forEach((k, v) {
        ledger.setEntry('rule.chain.$k', '$v');
      });
    }

    if (completeness == null) {
      ledger.setEntry('rule.completeness.present', 'missing');
    } else {
      ledger.setEntry('rule.completeness.present', 'ok');
      completeness.forEach((k, v) {
        ledger.setEntry('rule.completeness.$k', '$v');
      });
    }

    if (evaluator == null) {
      ledger.setEntry('rule.evaluator.present', 'missing');
    } else {
      ledger.setEntry('rule.evaluator.present', 'ok');
      evaluator.forEach((k, v) {
        ledger.setEntry('rule.evaluator.$k', '$v');
      });
    }
  }

  Map<String, dynamic> synthesizeReadiness({
    required Map<String, dynamic>? chainStatus,
    required Map<String, dynamic>? completeness,
    required Map<String, dynamic>? preflight,
    required bool hasDescriptor,
    required bool hasSkeleton,
    required bool hasVisualTier,
    required bool hasSurfaceTier,
    required bool hasRoleResolution,
    required bool hasStyleBinding,
  }) {
    final result = <String, dynamic>{};

    result['hasDescriptor'] = hasDescriptor;
    result['hasSkeleton'] = hasSkeleton;
    result['hasVisualTier'] = hasVisualTier;
    result['hasSurfaceTier'] = hasSurfaceTier;
    result['hasRoleResolution'] = hasRoleResolution;
    result['hasStyleBinding'] = hasStyleBinding;

    int score = 0;
    if (chainStatus != null) score++;
    if (completeness != null) score++;
    if (preflight != null) score++;
    if (hasDescriptor) score++;
    if (hasSkeleton) score++;
    if (hasVisualTier) score++;
    if (hasSurfaceTier) score++;
    if (hasRoleResolution) score++;
    if (hasStyleBinding) score++;

    String status;
    if (score == 0) {
      status = 'empty';
    } else if (score <= 3) {
      status = 'weak';
    } else if (score <= 6) {
      status = 'partial';
    } else if (score <= 8) {
      status = 'strong';
    } else {
      status = 'complete';
    }

    result['score'] = score;
    result['status'] = status;
    return result;
  }
}

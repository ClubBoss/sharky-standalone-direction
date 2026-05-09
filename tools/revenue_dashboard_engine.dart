// tools/revenue_dashboard_engine.dart
// Stage 26: Revenue Dashboard & Monetization Metrics (Mock)
//
// Computes revenue metrics from mock payment logs or gateway status.
// ASCII-only, pure Dart, no external dependencies.

import 'dart:convert';
import 'dart:io';

class RevenueMetricsResult {
  final double totalRevenue;
  final int activePremiums;
  final int totalUsers;
  final double conversionRate; // 0.0..1.0
  final double arpu; // revenue per user
  final bool pass;

  const RevenueMetricsResult({
    required this.totalRevenue,
    required this.activePremiums,
    required this.totalUsers,
    required this.conversionRate,
    required this.arpu,
    required this.pass,
  });

  Map<String, Object> toJson() => {
    'totalRevenue': totalRevenue,
    'activePremiums': activePremiums,
    'totalUsers': totalUsers,
    'conversionRate': conversionRate,
    'arpu': arpu,
    'pass': pass,
  };
}

/// Compute revenue metrics by scanning telemetry/payment_*.jsonl files.
/// If no logs are found, optionally fall back to a mock gateway status.
Future<Map<String, Object>> computeRevenueMetrics({
  int totalUsersHint = 0,
  Map<String, dynamic>? paymentGatewayStatus,
}) async {
  double totalRevenue = 0.0;
  final premiumUsers = <String>{};
  var foundAny = false;

  try {
    final dir = Directory('telemetry');
    if (await dir.exists()) {
      final files = await dir
          .list()
          .where(
            (e) => e is File && e.path.contains(RegExp(r'payment_.*\.jsonl$')),
          ) // jsonl only
          .cast<File>()
          .toList();
      for (final f in files) {
        final lines = await f.readAsLines();
        for (final line in lines) {
          final s = line.trim();
          if (s.isEmpty) continue;
          try {
            final obj = jsonDecode(s);
            if (obj is Map) {
              // Consider events with a receipt or type/product premium
              final hasReceipt =
                  (obj['receipt'] is String) &&
                  (obj['receipt'] as String).isNotEmpty;
              final isPremium =
                  (obj['type'] == 'premium') ||
                  (obj['product'] == 'premium') ||
                  hasReceipt;
              if (!isPremium) continue;
              foundAny = true;
              // Amount detection with fallbacks
              double amt = 0.0;
              final v = obj['amount'];
              if (v is num) {
                amt = v.toDouble();
              } else if (obj['priceUsd'] is num) {
                amt = (obj['priceUsd'] as num).toDouble();
              } else {
                // Fallback mock price
                amt = 9.99;
              }
              totalRevenue += amt;
              final uid = _asciiId(obj['userId'] ?? obj['uid'] ?? 'anon');
              premiumUsers.add(uid);
            }
          } catch (_) {
            /* ignore bad lines */
          }
        }
      }
    }
  } catch (_) {
    /* ignore directory errors */
  }

  // Fallback to gateway status if no logs
  if (!foundAny && (paymentGatewayStatus != null)) {
    if (paymentGatewayStatus['validated'] == true) {
      totalRevenue += 9.99;
      premiumUsers.add('mock-user');
      foundAny = true;
    }
  }

  final totalUsers = totalUsersHint > 0
      ? totalUsersHint
      : (premiumUsers.isNotEmpty ? premiumUsers.length : 100);
  final activePremiums = premiumUsers.length;
  final conversionRate = totalUsers > 0 ? activePremiums / totalUsers : 0.0;
  final arpu = totalUsers > 0 ? totalRevenue / totalUsers : 0.0;

  final pass = totalRevenue >= 0.0 && conversionRate >= 0.0 && arpu >= 0.0;

  return RevenueMetricsResult(
    totalRevenue: double.parse(totalRevenue.toStringAsFixed(2)),
    activePremiums: activePremiums,
    totalUsers: totalUsers,
    conversionRate: double.parse(conversionRate.toStringAsFixed(4)),
    arpu: double.parse(arpu.toStringAsFixed(2)),
    pass: pass,
  ).toJson();
}

String _asciiId(dynamic v) {
  final s = v?.toString() ?? 'anon';
  // Strip non-ASCII
  final filtered = s.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
  return filtered.isEmpty ? 'anon' : filtered;
}

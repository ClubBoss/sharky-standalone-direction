import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

class MonetizationService {
  MonetizationService._();

  static final MonetizationService instance = MonetizationService._();

  static const String _reportPath = 'release/_reports/monetization_events.json';

  final List<Map<String, Object?>> _buffer = <Map<String, Object?>>[];

  Future<void> trackAdView({
    required String placement,
    double revenueUsd = 0,
  }) async {
    final event = <String, Object?>{
      'type': 'ad_view',
      'placement': placement,
      'revenue_usd': revenueUsd,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    await _log(eventName: 'monetization_ad_view', payload: event);
  }

  Future<void> trackPremiumUpgrade({
    required String productId,
    double priceUsd = 0,
  }) async {
    final event = <String, Object?>{
      'type': 'premium_upgrade',
      'product_id': productId,
      'price_usd': priceUsd,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    await _log(eventName: 'monetization_premium_upgrade', payload: event);
  }

  Future<void> trackReferral(String code) async {
    final event = <String, Object?>{
      'type': 'referral',
      'code': code,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    await _log(eventName: 'monetization_referral', payload: event);
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) {
      return;
    }

    final file = File(_reportPath);
    await file.parent.create(recursive: true);

    final existing = <Map<String, Object?>>[];
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            for (final entry in decoded) {
              if (entry is Map) {
                existing.add(Map<String, Object?>.from(entry));
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('MonetizationService.flush parse skipped: $e');
        }
      }
    }

    existing.addAll(_buffer);
    _buffer.clear();

    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(existing)}\n');
  }

  Future<void> _log({
    required String eventName,
    required Map<String, Object?> payload,
  }) async {
    _buffer.add(payload);
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        eventName,
        params: payload,
      ),
    );
    await flush();
  }
}

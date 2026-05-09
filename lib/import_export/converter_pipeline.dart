import "dart:core" as core;
import 'dart:core';
import 'package:poker_analyzer/models/saved_hand.dart';
import 'package:poker_analyzer/plugins/converter_info.dart';
import 'package:poker_analyzer/plugins/converter_registry.dart';

/// High level pipeline for converting external hand formats.
///
/// This class coordinates with the shared [ConverterRegistry] to perform
/// conversions without duplicating registry lookup logic.
class ConverterPipeline {
  ConverterPipeline(this._registry);

  final ConverterRegistry _registry;

  /// Attempts to import [data] using the converter identified by [formatId].
  /// Returns a [SavedHand] on success or `null` if the converter is missing or
  /// the payload cannot be parsed.
  SavedHand? tryImport(String formatId, String data) =>
      _registry.tryConvert(formatId, data);

  /// Attempts to export [hand] using the converter identified by [formatId].
  /// Returns the serialized representation on success or `null` if the
  /// converter is unavailable or rejects the hand.
  String? tryExport(String formatId, SavedHand hand) =>
      _registry.tryExport(formatId, hand);

  /// Validates [hand] for export using the converter identified by [formatId].
  /// Returns an error message when validation fails, otherwise `null`.
  String? validateForExport(String formatId, SavedHand hand) =>
      _registry.validateForExport(formatId, hand);

  /// Lists format identifiers for which converters are registered.
  List<String> supportedFormats() => _registry.dumpFormatIds();

  /// Lists metadata for registered converters, optionally filtered by
  /// capability flags.
  List<ConverterInfo> availableConverters({
    bool? supportsImport,
    bool? supportsExport,
  }) => _registry.queryConverters(
    supportsImport: supportsImport,
    supportsExport: supportsExport,
  );
}

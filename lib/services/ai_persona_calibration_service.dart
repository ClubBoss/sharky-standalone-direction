import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _personaSummaryPath =
    '$_reportsDir/ai_persona_refinement_summary.json';
const String _resonanceSummaryPath =
    '$_reportsDir/ux_emotional_resonance_summary.json';

class AiPersonaCalibrationService {
  Future<AiPersonaCalibrationResult?> calibrate() async {
    final personaSummary = await _readJson(_personaSummaryPath);
    final resonanceSummary = await _readJson(_resonanceSummaryPath);
    if (personaSummary == null || resonanceSummary == null) {
      return null;
    }

    final toneConsistency =
        (personaSummary['tone_consistency'] as num?)?.toDouble() ?? 0;
    final personas = (personaSummary['personas'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => _PersonaEntry(
            name: entry['cluster']?.toString() ?? 'unknown',
            persona: entry['persona']?.toString() ?? '',
            sampleSize: (entry['sample_size'] as num?)?.toInt() ?? 0,
            clarity: (entry['clarity'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();

    final resonance =
        (resonanceSummary['average_resonance'] as num?)?.toDouble() ?? 0;

    if (personas.isEmpty) {
      return AiPersonaCalibrationResult.empty();
    }

    final alignments = <PersonaAlignment>[];
    for (final entry in personas) {
      final alignmentScore = (toneConsistency + resonance * 0.5) / 1.5;
      alignments.add(
        PersonaAlignment(
          cluster: entry.name,
          persona: entry.persona,
          alignment: alignmentScore.clamp(0, 1),
          sampleSize: entry.sampleSize,
        ),
      );
    }

    final alignmentAvg =
        alignments
            .map((a) => a.alignment)
            .fold<double>(0, (sum, value) => sum + value) /
        alignments.length;

    return AiPersonaCalibrationResult(
      alignments: alignments,
      averageAlignment: alignmentAvg.clamp(0, 1),
    );
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }
}

class AiPersonaCalibrationResult {
  const AiPersonaCalibrationResult({
    required this.alignments,
    required this.averageAlignment,
  });

  final List<PersonaAlignment> alignments;
  final double averageAlignment;

  static AiPersonaCalibrationResult empty() =>
      const AiPersonaCalibrationResult(alignments: [], averageAlignment: 0);
}

class PersonaAlignment {
  const PersonaAlignment({
    required this.cluster,
    required this.persona,
    required this.alignment,
    required this.sampleSize,
  });

  final String cluster;
  final String persona;
  final double alignment;
  final int sampleSize;
}

class _PersonaEntry {
  const _PersonaEntry({
    required this.name,
    required this.persona,
    required this.sampleSize,
    required this.clarity,
  });

  final String name;
  final String persona;
  final int sampleSize;
  final double clarity;
}

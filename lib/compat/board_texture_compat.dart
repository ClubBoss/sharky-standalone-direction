import 'dart:core';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/services/board_texture_classifier_service.dart';
import 'package:poker_analyzer/services/board_texture_classifier.dart';

extension BoardTextureClassifierCompat on BoardTextureClassifier {
  Map<String, List<String>> classifyAll(List<TrainingPackSpot> spots) =>
      BoardTextureClassifierService(classifier: this).classify(spots);
}

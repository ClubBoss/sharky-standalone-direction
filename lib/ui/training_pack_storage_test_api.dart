import 'dart:io';

import 'training_pack_storage_service_stub.dart';

void setTrainingPackStorageTestDirectory(Directory directory) {
  TrainingPackStorageService.setTestDirectory(directory);
}

void clearTrainingPackStorageTestDirectory() {
  TrainingPackStorageService.clearTestDirectory();
}

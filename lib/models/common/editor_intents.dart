import 'package:flutter/widgets.dart';

/// Sort orders used inside the training-pack editors.
enum SortBy { manual, title, evDesc, edited, autoEv }

/// Controls how spots are grouped within editor lists.
enum SortMode { position, chronological }

/// Common editor intents preserved from the legacy V2 tooling.
class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class DeleteBulkIntent extends Intent {
  const DeleteBulkIntent();
}

class DuplicateBulkIntent extends Intent {
  const DuplicateBulkIntent();
}

class TagBulkIntent extends Intent {
  const TagBulkIntent();
}

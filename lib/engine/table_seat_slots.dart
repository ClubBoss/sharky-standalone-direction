import 'dart:ui' show Offset;

import 'table_layout_resolver.dart';

class TableSeatSlot {
  const TableSeatSlot({required this.index, required this.position});

  final int index;
  final Offset position;
}

List<TableSeatSlot> buildTableSeatSlots(TableLayoutResolved resolved) {
  final slots = <TableSeatSlot>[];
  for (var i = 0; i < resolved.seatPositions.length; i++) {
    slots.add(TableSeatSlot(index: i, position: resolved.seatPositions[i]));
  }
  return slots;
}

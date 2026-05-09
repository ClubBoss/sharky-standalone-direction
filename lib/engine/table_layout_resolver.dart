import 'package:flutter/widgets.dart';

import 'table_layout_adapter.dart';
import 'table_shape.dart';

class TableLayoutResolved {
  const TableLayoutResolved({
    required this.seatPositions,
    required this.boardPosition,
    required this.dealerPosition,
  });

  final List<Offset> seatPositions;
  final Offset boardPosition;
  final Offset dealerPosition;
}

class TableLayoutResolver {
  const TableLayoutResolver({required this.adapter});

  final TableLayoutAdapter adapter;

  TableLayoutResolved resolve({
    required TableShapeSpec shape,
    required double width,
    required double height,
    required EdgeInsets safeArea,
  }) {
    final size = Size(width, height);
    final seats = TableLayoutAdapter.resolveSeats(shape.seats, size, safeArea);
    final board = TableLayoutAdapter.resolveBoard(shape.board, size, safeArea);
    final dealer = TableLayoutAdapter.resolveDealer(
      shape.dealer,
      size,
      safeArea,
    );
    return TableLayoutResolved(
      seatPositions: seats,
      boardPosition: board,
      dealerPosition: dealer,
    );
  }
}

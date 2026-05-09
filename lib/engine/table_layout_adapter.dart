import 'package:flutter/widgets.dart';

import 'table_layout_geometry.dart';
import 'table_layout_models.dart';

class TableLayoutAdapter {
  const TableLayoutAdapter();
  static const TableLayoutGeometry geometry = TableLayoutGeometry.defaults;
  static Offset resolve(Offset normalized, Size screenSize, EdgeInsets insets) {
    final usableWidth = screenSize.width - insets.left - insets.right;
    final usableHeight = screenSize.height - insets.top - insets.bottom;
    final realX = normalized.dx * usableWidth + insets.left;
    final realY = normalized.dy * usableHeight + insets.top;
    return Offset(realX, realY);
  }

  static List<Offset> resolveSeats(
    List<TableSeatAnchor> seats,
    Size screenSize,
    EdgeInsets insets,
  ) => seats
      .map((seat) => resolve(Offset(seat.x, seat.y), screenSize, insets))
      .toList();

  static Offset resolveBoard(
    TableBoardAnchor board,
    Size screenSize,
    EdgeInsets insets,
  ) => resolve(Offset(board.x, board.y), screenSize, insets);

  static Offset resolveDealer(
    TableDealerAnchor dealer,
    Size screenSize,
    EdgeInsets insets,
  ) => resolve(Offset(dealer.x, dealer.y), screenSize, insets);
}

import 'table_layout_models.dart';

class TableLayoutGeometry {
  const TableLayoutGeometry({
    required this.seats6,
    required this.seats9,
    required this.board,
    required this.dealer,
  });

  final List<TableSeatAnchor> seats6;
  final List<TableSeatAnchor> seats9;
  final TableBoardAnchor board;
  final TableDealerAnchor dealer;

  static const TableLayoutGeometry defaults = TableLayoutGeometry(
    seats6: [
      TableSeatAnchor(index: 0, x: 0.08, y: 0.6),
      TableSeatAnchor(index: 1, x: 0.28, y: 0.78),
      TableSeatAnchor(index: 2, x: 0.52, y: 0.9),
      TableSeatAnchor(index: 3, x: 0.72, y: 0.78),
      TableSeatAnchor(index: 4, x: 0.92, y: 0.6),
      TableSeatAnchor(index: 5, x: 0.68, y: 0.4),
    ],
    seats9: [
      TableSeatAnchor(index: 0, x: 0.05, y: 0.6),
      TableSeatAnchor(index: 1, x: 0.2, y: 0.8),
      TableSeatAnchor(index: 2, x: 0.4, y: 0.92),
      TableSeatAnchor(index: 3, x: 0.57, y: 0.92),
      TableSeatAnchor(index: 4, x: 0.73, y: 0.8),
      TableSeatAnchor(index: 5, x: 0.88, y: 0.6),
      TableSeatAnchor(index: 6, x: 0.82, y: 0.4),
      TableSeatAnchor(index: 7, x: 0.55, y: 0.2),
      TableSeatAnchor(index: 8, x: 0.25, y: 0.32),
    ],
    board: TableBoardAnchor(x: 0.5, y: 0.38),
    dealer: TableDealerAnchor(x: 0.5, y: 0.12),
  );
}

import 'table_layout_models.dart';

class TableLayoutEngine {
  const TableLayoutEngine({
    required this.seatAnchors,
    required this.boardAnchor,
    required this.dealerAnchor,
  });

  final List<TableSeatAnchor> seatAnchors;
  final TableBoardAnchor boardAnchor;
  final TableDealerAnchor dealerAnchor;
}

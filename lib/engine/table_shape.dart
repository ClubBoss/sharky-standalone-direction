import 'table_layout_geometry.dart';
import 'table_layout_models.dart';

enum TableShapeKind { sixMax, nineMax }

class TableShapeSpec {
  const TableShapeSpec._({
    required this.kind,
    required this.seats,
    required this.board,
    required this.dealer,
  });

  final TableShapeKind kind;
  final List<TableSeatAnchor> seats;
  final TableBoardAnchor board;
  final TableDealerAnchor dealer;

  factory TableShapeSpec.sixMax() => TableShapeSpec._(
    kind: TableShapeKind.sixMax,
    seats: TableLayoutGeometry.defaults.seats6,
    board: TableLayoutGeometry.defaults.board,
    dealer: TableLayoutGeometry.defaults.dealer,
  );

  factory TableShapeSpec.nineMax() => TableShapeSpec._(
    kind: TableShapeKind.nineMax,
    seats: TableLayoutGeometry.defaults.seats9,
    board: TableLayoutGeometry.defaults.board,
    dealer: TableLayoutGeometry.defaults.dealer,
  );
}

class TableSeatAnchor {
  const TableSeatAnchor({
    required this.index,
    required this.x,
    required this.y,
  });

  final int index;
  final double x;
  final double y;
}

class TableBoardAnchor {
  const TableBoardAnchor({required this.x, required this.y});

  final double x;
  final double y;
}

class TableDealerAnchor {
  const TableDealerAnchor({required this.x, required this.y});

  final double x;
  final double y;
}

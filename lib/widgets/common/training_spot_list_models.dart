enum SortOption {
  buyInAsc,
  buyInDesc,
  gameType,
  tournamentId,
  difficultyAsc,
  difficultyDesc,
}

enum SimpleSortField { createdAt, difficulty, rating }

enum SimpleSortOrder { ascending, descending }

class FilterState {
  const FilterState({
    required this.searchText,
    required this.selectedTags,
    required this.difficultyFilters,
    required this.ratingFilters,
    required this.icmOnly,
    required this.ratedOnly,
  });

  final String searchText;
  final Set<String> selectedTags;
  final Set<int> difficultyFilters;
  final Set<int> ratingFilters;
  final bool icmOnly;
  final bool ratedOnly;
}

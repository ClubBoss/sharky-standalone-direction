// Offline exhaustive equity for one chart opening range. See act0_preflop_equity_v1.dart.
#include <algorithm>
#include <array>
#include <cstdint>
#include <iostream>
#include <string>
#include <unordered_set>
#include <vector>

namespace {
constexpr char ranks[] = "23456789TJQKA";
constexpr int deckSize = 52;
constexpr int suitSize = 13;
constexpr int rankBits = (1 << suitSize) - 1;
using Scores = std::vector<int>;

struct Hole {
  int a;
  int b;
  int hand;
  bool inRange;
};

struct Count {
  uint64_t halfShares = 0;
  uint64_t deals = 0;
};

int straightHigh(int mask) {
  for (int high = 12; high >= 4; --high) {
    if ((mask >> (high - 4) & 31) == 31) return high;
  }
  return (mask & 0x100f) == 0x100f ? 3 : -1;
}

int score(int category, int a, int b = 0, int c = 0, int d = 0,
          int e = 0) {
  return category << 20 | a << 16 | b << 12 | c << 8 | d << 4 | e;
}

int highCards(int category, int mask) {
  int value = category << 20;
  int shift = 16;
  for (int rank = 12; rank >= 0 && shift >= 0; --rank) {
    if ((mask >> rank) & 1) {
      value |= rank << shift;
      shift -= 4;
    }
  }
  return value;
}

int bestRank(int mask) { return 31 - __builtin_clz(unsigned(mask)); }

int rankScore(const std::array<int, suitSize>& counts) {
  int present = 0, pairs = 0, trips = 0, quads = 0;
  for (int rank = 0; rank < suitSize; ++rank) {
    const int count = counts[rank];
    if (count) present |= 1 << rank;
    if (count >= 2) pairs |= 1 << rank;
    if (count >= 3) trips |= 1 << rank;
    if (count == 4) quads |= 1 << rank;
  }
  if (quads) {
    const int quad = bestRank(quads);
    return score(7, quad, bestRank(present ^ (1 << quad)));
  }
  if (trips) {
    const int trip = bestRank(trips);
    const int rest = pairs ^ (1 << trip);
    if (rest) return score(6, trip, bestRank(rest));
  }
  const int straight = straightHigh(present);
  if (straight >= 0) return score(4, straight);
  if (trips) {
    const int trip = bestRank(trips);
    const int rest = present ^ (1 << trip);
    const int first = bestRank(rest);
    return score(3, trip, first, bestRank(rest ^ (1 << first)));
  }
  if (pairs) {
    const int pair = bestRank(pairs);
    const int rest = present ^ (1 << pair);
    if (pairs != (1 << pair)) {
      const int second = bestRank(pairs ^ (1 << pair));
      return score(2, pair, second, bestRank(rest ^ (1 << second)));
    }
    const int first = bestRank(rest);
    const int second = bestRank(rest ^ (1 << first));
    return score(1, pair, first, second,
                 bestRank(rest ^ (1 << first) ^ (1 << second)));
  }
  return highCards(0, present);
}

std::string handCode(int a, int b) {
  const int high = std::max(a % suitSize, b % suitSize);
  const int low = std::min(a % suitSize, b % suitSize);
  std::string code{ranks[high], ranks[low]};
  if (high != low) code += a / suitSize == b / suitSize ? 's' : 'o';
  return code;
}

std::array<int, 4> canonicalSuits(uint64_t board) {
  return {
      int(board & rankBits), int(board >> 13 & rankBits),
      int(board >> 26 & rankBits), int(board >> 39 & rankBits),
  };
}

int multiplicity(const std::array<int, 4>& suits) {
  // There are 4! relabelings, with identical suit masks interchangeable.
  int divisor = 1;
  int same = 1;
  for (int i = 1; i < 4; ++i) {
    same = suits[i] == suits[i - 1] ? same + 1 : 1;
    divisor *= same;
  }
  return 24 / divisor;
}

std::pair<int, int> lowerAndEqual(const Scores& scores, int value) {
  const auto [lower, upper] = std::equal_range(scores.begin(), scores.end(), value);
  return {int(lower - scores.begin()), int(upper - lower)};
}

class Enumeration {
 public:
  Enumeration(const std::unordered_set<std::string>& range,
              const std::unordered_set<std::string>& direct) {
    for (int a = 0; a < deckSize; ++a) {
      for (int b = a + 1; b < deckSize; ++b) {
        const auto code = handCode(a, b);
        auto it = std::find(hands.begin(), hands.end(), code);
        if (it == hands.end()) {
          hands.push_back(code);
          it = hands.end() - 1;
        }
        const int index = int(it - hands.begin());
        const Hole hole{a, b, index, range.count(code) != 0};
        if (hole.inRange) villains.push_back(hole);
        if (direct.empty() || direct.count(code)) heroes.push_back(hole);
      }
    }
    counts.resize(hands.size());
    scores.reserve(villains.size());
    for (auto& containing : scoresWithCard) containing.reserve(deckSize);
  }

  void run(bool compareDirectly) {
    uint64_t board = 31;
    constexpr uint64_t limit = uint64_t{1} << deckSize;
    for (; board < limit;) {
      const auto suits = canonicalSuits(board);
      if (suits[0] >= suits[1] && suits[1] >= suits[2] && suits[2] >= suits[3]) {
        prepare(board, suits);
        if (compareDirectly) {
          countDirectly(board, multiplicity(suits));
        } else {
          countByRank(board, multiplicity(suits));
        }
      }
      const uint64_t bit = board & -board;
      const uint64_t next = board + bit;
      board = next | ((next ^ board) >> (__builtin_ctzll(bit) + 2));
    }
  }

  void print() const {
    for (size_t i = 0; i < counts.size(); ++i) {
      if (counts[i].deals) {
        std::cout << hands[i] << ' ' << counts[i].halfShares << ' '
                  << counts[i].deals << '\n';
      }
    }
  }

 private:
  std::vector<std::string> hands;
  std::vector<Hole> heroes, villains;
  std::vector<Count> counts;
  Scores scores;
  std::array<Scores, deckSize> scoresWithCard;
  std::array<std::array<int, suitSize>, suitSize> ranksOnBoard{};
  int flushSuit = -1, flushBoard = 0;

  void prepare(uint64_t board, const std::array<int, 4>& suits) {
    std::array<int, suitSize> rankCounts{};
    for (; board; board &= board - 1) ++rankCounts[__builtin_ctzll(board) % suitSize];
    for (int a = 0; a < suitSize; ++a) {
      if (rankCounts[a] == 4) continue;
      ++rankCounts[a];
      for (int b = a; b < suitSize; ++b) {
        if (rankCounts[b] == 4) continue;
        ++rankCounts[b];
        ranksOnBoard[a][b] = ranksOnBoard[b][a] = rankScore(rankCounts);
        --rankCounts[b];
      }
      --rankCounts[a];
    }
    flushSuit = -1;
    for (int suit = 0; suit < 4; ++suit) {
      if (__builtin_popcount(suits[suit]) >= 3) {
        flushSuit = suit;
        flushBoard = suits[suit];
        break;
      }
    }
  }

  int evaluate(const Hole& hole) const {
    const int a = hole.a % suitSize, b = hole.b % suitSize;
    const int value = ranksOnBoard[a][b];
    if (flushSuit == -1) return value;
    int suited = flushBoard;
    if (hole.a / suitSize == flushSuit) suited |= 1 << a;
    if (hole.b / suitSize == flushSuit) suited |= 1 << b;
    if (__builtin_popcount(suited) < 5) return value;
    const int straight = straightHigh(suited);
    const int flush = straight >= 0 ? score(8, straight) : highCards(5, suited);
    return std::max(flush, value);
  }

  static uint64_t mask(const Hole& hole) {
    return uint64_t{1} << hole.a | uint64_t{1} << hole.b;
  }

  void countByRank(uint64_t board, int weight) {
    scores.clear();
    for (auto& containing : scoresWithCard) containing.clear();
    for (const auto& villain : villains) {
      if (mask(villain) & board) continue;
      const int value = evaluate(villain);
      scores.push_back(value);
      scoresWithCard[villain.a].push_back(value);
      scoresWithCard[villain.b].push_back(value);
    }
    std::sort(scores.begin(), scores.end());
    for (auto& containing : scoresWithCard) {
      std::sort(containing.begin(), containing.end());
    }
    for (const auto& hero : heroes) {
      if (mask(hero) & board) continue;
      const int value = evaluate(hero);
      const auto [wins, ties] = lowerAndEqual(scores, value);
      const auto [winsA, tiesA] = lowerAndEqual(scoresWithCard[hero.a], value);
      const auto [winsB, tiesB] = lowerAndEqual(scoresWithCard[hero.b], value);
      // Inclusion–exclusion removes villain pockets blocked by either card.
      // Only the hero's exact pocket is in both blocked lists, and it ties.
      counts[hero.hand].halfShares +=
          weight * (2 * (wins - winsA - winsB) + ties - tiesA - tiesB + hero.inRange);
      counts[hero.hand].deals += weight *
          (scores.size() - scoresWithCard[hero.a].size() -
           scoresWithCard[hero.b].size() + hero.inRange);
    }
  }

  void countDirectly(uint64_t board, int weight) {
    // Independent blocker and outcome counting. Visit each legal matchup.
    std::vector<std::pair<uint64_t, int>> legal;
    legal.reserve(villains.size());
    for (const auto& villain : villains) {
      if (!(mask(villain) & board)) legal.emplace_back(mask(villain), evaluate(villain));
    }
    for (const auto& hero : heroes) {
      const auto pocket = mask(hero);
      if (pocket & board) continue;
      const int strength = evaluate(hero);
      for (const auto& [other, value] : legal) {
        if (pocket & other) continue;
        counts[hero.hand].deals += weight;
        if (strength >= value) {
          counts[hero.hand].halfShares += weight * (strength > value ? 2 : 1);
        }
      }
    }
  }
};
}  // namespace

int main() {
  std::unordered_set<std::string> range, direct;
  int size = 0;
  if (!(std::cin >> size) || size <= 0 || size > 169) return 1;
  for (int i = 0; i < size; ++i) {
    std::string hand;
    if (!(std::cin >> hand) || !range.insert(hand).second) return 1;
  }
  std::string hand;
  while (std::cin >> hand) direct.insert(hand);
  Enumeration enumeration(range, direct);
  enumeration.run(!direct.empty());
  enumeration.print();
}

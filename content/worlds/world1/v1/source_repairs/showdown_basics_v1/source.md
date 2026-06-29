# W1 Showdown Basics Source Repair

## Objective

Build the beginner showdown habit: find the best five-card hand for each player,
then compare those hands before naming a winner.

## Scenario

Each rep uses either two named hand ranks or fully visible hole and board cards.
The learner identifies the strongest five-card result before choosing the
higher hand, the winning player, or `board plays` when both players tie.

## Decision

Choose the higher hand rank or the player whose best five cards are stronger.
Use a kicker only after the main hand rank ties. Choose `board plays` when both
players use the same best five cards from the board.

## Explanation

Begin with hand-rank order, then build the best five cards from the seven
available cards. Compare the resulting five-card hands. Only after the main
rank ties should a remaining kicker decide the winner.

## Hand-Rank Order

From lower to higher, the basic order is high card, one pair, two pair, three
of a kind, straight, flush, full house, four of a kind, and straight flush.
A higher hand rank beats a lower hand rank before any kicker is considered.

## Best Five From Seven

In hold'em, each player can see seven available cards at the river: two hole
cards and five board cards. The player's hand is the strongest five-card hand
that can be made from those seven cards. The best five may use both hole cards,
one hole card, or no hole cards when the board already makes the best hand.

## Showdown And Kicker

At showdown, compare each player's best five cards. The higher hand rank wins.
If the main hand rank ties, the remaining card in the best five can be a
kicker that breaks the tie. A kicker never makes a lower hand rank beat a
higher hand rank. If both players use the same best five cards from the board,
the result is a tie.

## Scope

This session covers visible-card beginner comparisons only. It does not teach
strategy or every rare hand-comparison edge case.

import '../models/training_league_member.dart';
import '../models/training_league_status.dart';

/// Provides mock training league data for the MVP experience.
class TrainingLeagueService {
  TrainingLeagueService._();

  static final TrainingLeagueService instance = TrainingLeagueService._();

  /// Returns the mock league status for the current user.
  TrainingLeagueStatus getStatus() {
    // Stubbed season data; replace with real sync once PvP launches.
    return const TrainingLeagueStatus(
      leagueId: 'league_alpha',
      joined: true,
      wins: 5,
      losses: 3,
      rank: 'Challenger',
    );
  }

  /// Returns a mock leaderboard for the active league.
  List<TrainingLeagueMember> getLeaderboard() => const [
    TrainingLeagueMember(
      rank: 1,
      displayName: 'RazorRick',
      xp: 18250,
      isMe: false,
    ),
    TrainingLeagueMember(
      rank: 2,
      displayName: 'SolverSue',
      xp: 17210,
      isMe: false,
    ),
    TrainingLeagueMember(
      rank: 3,
      displayName: 'GrinderGwen',
      xp: 16640,
      isMe: false,
    ),
    TrainingLeagueMember(
      rank: 4,
      displayName: 'CoachConnor',
      xp: 16100,
      isMe: false,
    ),
    TrainingLeagueMember(rank: 5, displayName: 'You', xp: 15890, isMe: true),
  ];
}

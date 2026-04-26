/// Pure-Dart stats primitives used by the tournament list & game list pages.
///
/// These helpers were lifted out of the UI widgets so they can be unit-tested
/// without booting a Flutter binding or mocking Firestore. The widgets now
/// convert their Firestore records into the plain [ScoreEntry] shape below and
/// delegate the math here, which keeps one source of truth for "did the user
/// win this matchup?" and "which archetype did they play the most?".
library;

/// Plain record of a single player's result in a matchup. A matchup is the
/// list of these for everyone involved — 2 for a duel, 3+ for an EDH-style
/// pod. Keeping this struct free of Firestore references is what lets the
/// aggregation functions below stay pure.
class ScoreEntry {
  const ScoreEntry({required this.deckId, required this.score});
  final String deckId;
  final int score;
}

/// Display metadata attached to one of the user's own decks. Used only to
/// label the top-archetype chips in the stats strip; the actual tally logic
/// is agnostic of [avatarUrl].
class DeckArchetypeInfo {
  const DeckArchetypeInfo({required this.name, this.avatarUrl});
  final String name;
  final String? avatarUrl;
}

/// Mutable running tally for one archetype. We expose `wins`, `losses` and
/// `draws` rather than a single pre-computed winrate so the caller can decide
/// how to render confidence (e.g. hide winrate under 5 games).
class ArchetypeTally {
  ArchetypeTally({required this.name, this.avatarUrl});
  final String name;
  String? avatarUrl;
  int games = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;

  /// Integer percentage, floor-rounded. Returns 0 when no games were played.
  int get winRatePct => games > 0 ? (wins / games * 100).round() : 0;
}

/// Returns the user's deckId for this matchup, or null if they didn't play.
///
/// We iterate every score instead of just the first two because the same
/// helper is used on manual matchups (always 2 scores) and imported Spicerack
/// events (always 2 scores for Swiss rounds, but we keep the contract general
/// in case we ever support pods).
String? myPlayedDeckId(List<ScoreEntry> scores, Set<String> myDeckIds) {
  if (scores.isEmpty) return null;
  for (final s in scores) {
    if (myDeckIds.contains(s.deckId)) return s.deckId;
  }
  return null;
}

/// Returns +1 if the user won, -1 if they lost, 0 on draw, or null if they
/// weren't in this matchup or it was mal-formed (fewer than 2 scores).
///
/// We compare the user's score to the *highest* opposing score so 3-player
/// pods degrade sensibly: the user wins only if they strictly out-scored the
/// best opponent.
int? userResult(List<ScoreEntry> scores, Set<String> myDeckIds) {
  if (scores.length < 2) return null;
  ScoreEntry? mine;
  var bestOpponent = -1 << 31; // min int
  for (final s in scores) {
    if (mine == null && myDeckIds.contains(s.deckId)) {
      mine = s;
    } else {
      if (s.score > bestOpponent) bestOpponent = s.score;
    }
  }
  if (mine == null) return null;
  if (mine.score > bestOpponent) return 1;
  if (mine.score < bestOpponent) return -1;
  return 0;
}

/// Aggregates the user's archetype stats over an iterable of matchups,
/// returning tallies sorted by game count descending (then alphabetically
/// by archetype name for stable display).
///
/// Matchups where the user didn't play, or where their deck id isn't keyed
/// in [deckArchetype], are silently skipped — they don't contribute to any
/// archetype bucket.
List<ArchetypeTally> aggregateArchetypeTally({
  required Iterable<List<ScoreEntry>> matchups,
  required Set<String> myDeckIds,
  required Map<String, DeckArchetypeInfo> deckArchetype,
}) {
  final tally = <String, ArchetypeTally>{};
  for (final scores in matchups) {
    final deckId = myPlayedDeckId(scores, myDeckIds);
    if (deckId == null) continue;
    final info = deckArchetype[deckId];
    if (info == null) continue;
    final key = info.name.toLowerCase();
    final bucket = tally.putIfAbsent(
      key,
      () => ArchetypeTally(name: info.name, avatarUrl: info.avatarUrl),
    );
    // Late-binding avatar: a deck tagged with an art_crop after another
    // deck in the same bucket should still expose it.
    bucket.avatarUrl ??= info.avatarUrl;

    final r = userResult(scores, myDeckIds);
    if (r == null) continue;
    bucket.games += 1;
    if (r > 0) {
      bucket.wins += 1;
    } else if (r < 0) {
      bucket.losses += 1;
    } else {
      bucket.draws += 1;
    }
  }
  final list = tally.values.toList();
  list.sort((a, b) {
    final byGames = b.games.compareTo(a.games);
    if (byGames != 0) return byGames;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return list;
}

/// Rolls up a global W/L/D record over the same matchup iterable, optionally
/// filtered by a single archetype (case-insensitive match against
/// [DeckArchetypeInfo.name]).
///
/// Returned as a 3-tuple `(wins, losses, draws)`; callers compute winrate
/// themselves because the rendering rules vary (hidden when games == 0,
/// small grey when < 5, etc).
({int wins, int losses, int draws}) globalRecord({
  required Iterable<List<ScoreEntry>> matchups,
  required Set<String> myDeckIds,
  required Map<String, DeckArchetypeInfo> deckArchetype,
  String? archetypeName,
}) {
  var wins = 0, losses = 0, draws = 0;
  final filterKey = archetypeName?.toLowerCase();
  for (final scores in matchups) {
    if (filterKey != null) {
      final deckId = myPlayedDeckId(scores, myDeckIds);
      if (deckId == null) continue;
      final info = deckArchetype[deckId];
      if (info == null || info.name.toLowerCase() != filterKey) continue;
    }
    final r = userResult(scores, myDeckIds);
    if (r == null) continue;
    if (r > 0) {
      wins++;
    } else if (r < 0) {
      losses++;
    } else {
      draws++;
    }
  }
  return (wins: wins, losses: losses, draws: draws);
}

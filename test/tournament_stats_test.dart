/// Unit tests for the tournament/games stats primitives living in
/// `lib/backend/stats/tournament_stats.dart`. No Firestore, no Flutter
/// binding — just the plain-Dart math that the UI depends on.
///
/// These cover the logic that was previously trapped inside private methods
/// on the tournament_list / c2_game_list widgets. Anything that regresses
/// here will visibly break the top-archetype strip and the winrate badges.
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/backend/stats/tournament_stats.dart';

/// Shorthand builder for a 1v1 matchup. First argument is the user, second
/// the opponent. Makes the test bodies readable at a glance.
List<ScoreEntry> duel({
  required String myDeck,
  required int myScore,
  required String oppDeck,
  required int oppScore,
}) =>
    [
      ScoreEntry(deckId: myDeck, score: myScore),
      ScoreEntry(deckId: oppDeck, score: oppScore),
    ];

void main() {
  group('myPlayedDeckId', () {
    test('returns the user deck id when one of the scores matches', () {
      final scores = duel(
        myDeck: 'reanimator',
        myScore: 2,
        oppDeck: 'delver',
        oppScore: 1,
      );
      expect(myPlayedDeckId(scores, {'reanimator'}), 'reanimator');
    });

    test('returns null when the user didn\'t play', () {
      final scores = duel(
        myDeck: 'delver',
        myScore: 2,
        oppDeck: 'jund',
        oppScore: 0,
      );
      expect(myPlayedDeckId(scores, {'reanimator'}), null);
    });

    test('returns null on an empty matchup', () {
      expect(myPlayedDeckId(const [], {'reanimator'}), null);
    });

    test('returns the user deck id even in a 3-player pod', () {
      final scores = [
        ScoreEntry(deckId: 'opp-a', score: 1),
        ScoreEntry(deckId: 'me', score: 2),
        ScoreEntry(deckId: 'opp-b', score: 0),
      ];
      expect(myPlayedDeckId(scores, {'me'}), 'me');
    });
  });

  group('userResult', () {
    test('+1 on a clear win', () {
      expect(
        userResult(
          duel(myDeck: 'me', myScore: 2, oppDeck: 'opp', oppScore: 1),
          {'me'},
        ),
        1,
      );
    });

    test('-1 on a clear loss', () {
      expect(
        userResult(
          duel(myDeck: 'me', myScore: 0, oppDeck: 'opp', oppScore: 2),
          {'me'},
        ),
        -1,
      );
    });

    test('0 on a tie', () {
      expect(
        userResult(
          duel(myDeck: 'me', myScore: 1, oppDeck: 'opp', oppScore: 1),
          {'me'},
        ),
        0,
      );
    });

    test('null when the user is not in the matchup', () {
      expect(
        userResult(
          duel(myDeck: 'a', myScore: 2, oppDeck: 'b', oppScore: 1),
          {'me'},
        ),
        null,
      );
    });

    test('null when the matchup has fewer than 2 players', () {
      expect(
        userResult(
          [ScoreEntry(deckId: 'me', score: 3)],
          {'me'},
        ),
        null,
      );
    });

    test('in a 3-player pod, wins only if I beat the best opponent', () {
      // User scores 2, opponents scored 3 and 0 — so user didn't top.
      final scores = [
        ScoreEntry(deckId: 'me', score: 2),
        ScoreEntry(deckId: 'opp-a', score: 3),
        ScoreEntry(deckId: 'opp-b', score: 0),
      ];
      expect(userResult(scores, {'me'}), -1);
    });

    test('in a 3-player pod, tying the top opponent is a draw', () {
      final scores = [
        ScoreEntry(deckId: 'me', score: 2),
        ScoreEntry(deckId: 'opp-a', score: 2),
        ScoreEntry(deckId: 'opp-b', score: 0),
      ];
      expect(userResult(scores, {'me'}), 0);
    });
  });

  group('aggregateArchetypeTally', () {
    // Two user decks tagged with distinct archetypes. The user plays 4
    // matchups: 2 Reanimator (1 W, 1 L), 2 Delver (1 W, 1 D). Expected
    // top list sorted by games desc; tie-broken alphabetically.
    final myDecks = {'deck-rean', 'deck-delver'};
    final deckArch = {
      'deck-rean': const DeckArchetypeInfo(
          name: 'Reanimator', avatarUrl: 'https://cdn/rean.png'),
      'deck-delver': const DeckArchetypeInfo(name: 'Delver'),
    };
    final matchups = [
      // Reanimator wins
      duel(myDeck: 'deck-rean', myScore: 2, oppDeck: 'opp', oppScore: 1),
      // Reanimator loses
      duel(myDeck: 'deck-rean', myScore: 0, oppDeck: 'opp', oppScore: 2),
      // Delver wins
      duel(myDeck: 'deck-delver', myScore: 2, oppDeck: 'opp', oppScore: 0),
      // Delver draws
      duel(myDeck: 'deck-delver', myScore: 1, oppDeck: 'opp', oppScore: 1),
    ];

    test('tallies wins/losses/draws per archetype', () {
      final tallies = aggregateArchetypeTally(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
      );
      expect(tallies.length, 2);

      final reanimator =
          tallies.firstWhere((t) => t.name == 'Reanimator');
      expect(reanimator.games, 2);
      expect(reanimator.wins, 1);
      expect(reanimator.losses, 1);
      expect(reanimator.draws, 0);
      expect(reanimator.avatarUrl, 'https://cdn/rean.png');
      expect(reanimator.winRatePct, 50);

      final delver = tallies.firstWhere((t) => t.name == 'Delver');
      expect(delver.games, 2);
      expect(delver.wins, 1);
      expect(delver.draws, 1);
      expect(delver.winRatePct, 50);
    });

    test('ties in game count sort alphabetically', () {
      final tallies = aggregateArchetypeTally(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
      );
      // Both have 2 games → Delver before Reanimator alphabetically.
      expect(tallies.map((t) => t.name).toList(), ['Delver', 'Reanimator']);
    });

    test('skips matchups where the user played an untagged deck', () {
      final sparseArch = {'deck-rean': const DeckArchetypeInfo(name: 'Reanimator')};
      final tallies = aggregateArchetypeTally(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: sparseArch,
      );
      // Only Reanimator is tagged; Delver games should be dropped from the
      // aggregate entirely (not pollute "Other" or similar).
      expect(tallies.map((t) => t.name).toList(), ['Reanimator']);
      expect(tallies.first.games, 2);
    });

    test('skips matchups where the user did not play', () {
      final foreign = [
        duel(myDeck: 'x', myScore: 2, oppDeck: 'y', oppScore: 1),
      ];
      final tallies = aggregateArchetypeTally(
        matchups: foreign,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
      );
      expect(tallies, isEmpty);
    });

    test('later avatar wins the tie-break when the first tally was blank', () {
      // Two decks → same archetype; first is unlabeled, second has art.
      final decks = {
        'd1': const DeckArchetypeInfo(name: 'Reanimator'),
        'd2': const DeckArchetypeInfo(
            name: 'Reanimator', avatarUrl: 'https://cdn/late.png'),
      };
      final m = [
        duel(myDeck: 'd1', myScore: 2, oppDeck: 'o', oppScore: 1),
        duel(myDeck: 'd2', myScore: 2, oppDeck: 'o', oppScore: 1),
      ];
      final tallies = aggregateArchetypeTally(
        matchups: m,
        myDeckIds: {'d1', 'd2'},
        deckArchetype: decks,
      );
      expect(tallies.length, 1);
      expect(tallies.first.avatarUrl, 'https://cdn/late.png');
      expect(tallies.first.games, 2);
    });
  });

  group('globalRecord', () {
    final myDecks = {'deck-rean', 'deck-delver'};
    final deckArch = {
      'deck-rean': const DeckArchetypeInfo(name: 'Reanimator'),
      'deck-delver': const DeckArchetypeInfo(name: 'Delver'),
    };
    final matchups = [
      duel(myDeck: 'deck-rean', myScore: 2, oppDeck: 'opp', oppScore: 1),
      duel(myDeck: 'deck-rean', myScore: 0, oppDeck: 'opp', oppScore: 2),
      duel(myDeck: 'deck-delver', myScore: 2, oppDeck: 'opp', oppScore: 0),
      duel(myDeck: 'deck-delver', myScore: 1, oppDeck: 'opp', oppScore: 1),
    ];

    test('without archetype filter: sums across all of the user\'s matchups',
        () {
      final r = globalRecord(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
      );
      expect(r.wins, 2);
      expect(r.losses, 1);
      expect(r.draws, 1);
    });

    test('with archetype filter: only counts that archetype\'s matchups', () {
      final r = globalRecord(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
        archetypeName: 'Reanimator',
      );
      expect(r.wins, 1);
      expect(r.losses, 1);
      expect(r.draws, 0);
    });

    test('archetype filter is case-insensitive', () {
      final r = globalRecord(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
        archetypeName: 'REANIMATOR',
      );
      expect(r.wins, 1);
      expect(r.losses, 1);
    });

    test('matchups with an unknown archetype are dropped when filtering', () {
      final r = globalRecord(
        matchups: matchups,
        myDeckIds: myDecks,
        deckArchetype: deckArch,
        archetypeName: 'Dragons',
      );
      expect(r, (wins: 0, losses: 0, draws: 0));
    });
  });
}

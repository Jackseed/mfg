import 'dart:convert';
import 'package:http/http.dart' as http;

/// Lightweight data classes for Spicerack API responses.

class SpicerackEvent {
  final int id;
  final String name;
  final String format;
  final DateTime? startDate;
  final int? conventionId;
  final String? conventionName;
  final int organizerId;
  final String organizerName;

  SpicerackEvent({
    required this.id,
    required this.name,
    required this.format,
    this.startDate,
    this.conventionId,
    this.conventionName,
    required this.organizerId,
    required this.organizerName,
  });
}

class SpicerackRegistration {
  final int userEventStatusId;
  final int userId;
  final String userIdentifier;
  final String email;
  final int matchesWon;
  final int matchesLost;
  final int matchesDrawn;
  final int? decklistId;

  SpicerackRegistration({
    required this.userEventStatusId,
    required this.userId,
    required this.userIdentifier,
    required this.email,
    required this.matchesWon,
    required this.matchesLost,
    required this.matchesDrawn,
    this.decklistId,
  });

  factory SpicerackRegistration.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final decklist = json['decklist'];
    return SpicerackRegistration(
      userEventStatusId: json['id'] as int,
      userId: user['id'] as int? ?? 0,
      userIdentifier: json['user_identifier'] as String? ?? '',
      email: user['email'] as String? ?? '',
      matchesWon: json['matches_won'] as int? ?? 0,
      matchesLost: json['matches_lost'] as int? ?? 0,
      matchesDrawn: json['matches_drawn'] as int? ?? 0,
      decklistId: decklist is Map ? decklist['id'] as int? : decklist as int?,
    );
  }
}

class SpicerackMatchPlayer {
  final int userId;
  final String name;
  final int gamesWon;

  SpicerackMatchPlayer({
    required this.userId,
    required this.name,
    required this.gamesWon,
  });
}

class SpicerackMatch {
  final int id;
  final int roundNumber;
  final List<SpicerackMatchPlayer> players;

  SpicerackMatch({
    required this.id,
    required this.roundNumber,
    required this.players,
  });

  /// True if this is a 1v1 match (exactly 2 real players).
  bool get isOneVsOne => players.length == 2;
}

class SpicerackDecklist {
  final int id;
  final String name;
  final String? archetype;
  final String? moxfieldPublicId;

  SpicerackDecklist({
    required this.id,
    required this.name,
    this.archetype,
    this.moxfieldPublicId,
  });

  String? get moxfieldUrl => moxfieldPublicId != null && moxfieldPublicId!.isNotEmpty
      ? 'https://www.moxfield.com/decks/$moxfieldPublicId'
      : null;
}

/// Result of scanning all events for a player.
class PlayerEventResult {
  final SpicerackEvent event;
  final SpicerackRegistration registration;
  final List<SpicerackMatch> matches;
  final Map<int, SpicerackRegistration> allRegistrations; // userId -> reg
  final Map<int, SpicerackDecklist> decklists; // userId -> decklist

  PlayerEventResult({
    required this.event,
    required this.registration,
    required this.matches,
    required this.allRegistrations,
    required this.decklists,
  });
}

/// Lightweight representation of a user's event from /api/event-statuses/.
class SpicerackUserEventStatus {
  final int userEventStatusId;
  final int eventId;
  final String eventName;
  final String eventFormat;
  final DateTime? startDate;
  final int? conventionId;
  final String? conventionName;
  final int organizerId;
  final String organizerName;
  final int matchesWon;
  final int matchesLost;
  final int matchesDrawn;
  final String registrationStatus;

  SpicerackUserEventStatus({
    required this.userEventStatusId,
    required this.eventId,
    required this.eventName,
    required this.eventFormat,
    this.startDate,
    this.conventionId,
    this.conventionName,
    required this.organizerId,
    required this.organizerName,
    required this.matchesWon,
    required this.matchesLost,
    required this.matchesDrawn,
    required this.registrationStatus,
  });

  factory SpicerackUserEventStatus.fromJson(Map<String, dynamic> json) {
    final me = json['magic_event'] as Map<String, dynamic>? ?? {};
    final convention = me['convention'] as Map<String, dynamic>?;
    final store = me['store'] as Map<String, dynamic>?;

    // Organizer info: prefer convention.organizer, fallback to store
    int organizerId = 0;
    String organizerName = 'Unknown';
    if (convention != null) {
      final org = convention['organizer'] as Map<String, dynamic>?;
      if (org != null) {
        organizerId = org['id'] as int? ?? 0;
        organizerName = org['name'] as String? ?? 'Unknown';
      }
    }
    if (organizerId == 0 && store != null) {
      organizerId = store['id'] as int? ?? 0;
      organizerName = store['name'] as String? ?? 'Unknown';
    }

    DateTime? startDate;
    final dateStr = me['start_datetime'] as String?;
    if (dateStr != null) {
      startDate = DateTime.tryParse(dateStr);
    }

    return SpicerackUserEventStatus(
      userEventStatusId: json['id'] as int,
      eventId: me['id'] as int? ?? 0,
      eventName: me['name'] as String? ?? 'Unknown',
      eventFormat: me['event_format'] as String? ?? '',
      startDate: startDate,
      conventionId: convention?['id'] as int?,
      conventionName: convention?['name'] as String?,
      organizerId: organizerId,
      organizerName: organizerName,
      matchesWon: json['matches_won'] as int? ?? 0,
      matchesLost: json['matches_lost'] as int? ?? 0,
      matchesDrawn: json['matches_drawn'] as int? ?? 0,
      registrationStatus: json['registration_status'] as String? ?? '',
    );
  }
}

/// Thrown when the Spicerack session has expired.
class SpicerackSessionExpiredException implements Exception {
  @override
  String toString() => 'Spicerack session expired. Please log in again.';
}

/// Service for calling the Spicerack API.
class SpicerackService {
  static const String _baseUrl = 'https://api.spicerack.gg/api/v1';
  static const String _apiKey =
      'sk_38sKNuJeMGu8unhiNKfxMVrnkG6caHxfuHBPgY2dLj07gtMW';

  static const Set<String> oneVsOneFormats = {
    'MODERN',
    'PIONEER',
    'LEGACY',
    'STANDARD',
    'VINTAGE',
    'PAUPER',
  };

  Map<String, String> get _headers => {
        'X-API-Key': _apiKey,
        'Accept': 'application/json',
      };

  /// GET helper with error handling.
  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
        'Spicerack API error ${response.statusCode}: ${response.body}');
  }

  // ─── Session-based internal API ───────────────────────────────

  /// Fetch all events the logged-in user participated in.
  /// Requires the session cookie from spicerack.gg login.
  Future<List<SpicerackUserEventStatus>> fetchUserEventStatuses(
      String sessionId) async {
    final uri = Uri.parse('https://api.spicerack.gg/api/event-statuses/');
    final response = await http.get(uri, headers: {
      'Cookie': 'sessionid=$sessionId',
      'Accept': 'application/json',
      'Referer': 'https://www.spicerack.gg/',
      'Origin': 'https://www.spicerack.gg',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data
          .cast<Map<String, dynamic>>()
          .map((json) => SpicerackUserEventStatus.fromJson(json))
          .toList();
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw SpicerackSessionExpiredException();
    }
    throw Exception(
        'Event statuses API error ${response.statusCode}: ${response.body}');
  }

  // ─── Build full results from selected events ──────────────────

  /// Build PlayerEventResult list from selected user event statuses.
  /// Uses the public API (with API key) to fetch full details.
  Future<List<PlayerEventResult>> buildPlayerEventResults({
    required List<SpicerackUserEventStatus> statuses,
    void Function(int current, int total, String status)? onProgress,
  }) async {
    final results = <PlayerEventResult>[];

    for (var i = 0; i < statuses.length; i++) {
      final status = statuses[i];
      onProgress?.call(
          i + 1, statuses.length, 'Loading ${status.eventName}...');

      final event = SpicerackEvent(
        id: status.eventId,
        name: status.eventName,
        format: status.eventFormat,
        startDate: status.startDate,
        conventionId: status.conventionId,
        conventionName: status.conventionName,
        organizerId: status.organizerId,
        organizerName: status.organizerName,
      );

      try {
        final eventDetail = await getEventDetails(status.eventId);
        final matches = parseMatches(eventDetail);
        final registrations = await getEventRegistrations(status.eventId);

        // Find this user's registration
        SpicerackRegistration? playerReg;
        for (final r in registrations) {
          if (r.userEventStatusId == status.userEventStatusId) {
            playerReg = r;
            break;
          }
        }
        playerReg ??= registrations.isNotEmpty ? registrations.first : null;
        if (playerReg == null) continue;

        final allRegs = <int, SpicerackRegistration>{};
        for (final r in registrations) {
          allRegs[r.userId] = r;
        }

        // Parse decklists
        Map<int, SpicerackDecklist> decklists = {};
        try {
          final rawRegs =
              await _get('/magic-events/${status.eventId}/registrations/');
          decklists = parseDecklists(
              (rawRegs as List).cast<Map<String, dynamic>>());
        } catch (e) {
          print('[SpicerackService] Error parsing decklists: $e');
        }

        results.add(PlayerEventResult(
          event: event,
          registration: playerReg,
          matches: matches,
          allRegistrations: allRegs,
          decklists: decklists,
        ));
      } catch (e) {
        print('[SpicerackService] Error loading event ${status.eventId}: $e');
      }
    }

    return results;
  }

  // ─── Public API methods ───────────────────────────────────────

  /// Get registrations for an event (includes player emails).
  Future<List<SpicerackRegistration>> getEventRegistrations(
      int eventId) async {
    try {
      final data = await _get('/magic-events/$eventId/registrations/');
      return (data as List)
          .cast<Map<String, dynamic>>()
          .map((j) => SpicerackRegistration.fromJson(j))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get full event details (tournament phases, matches).
  Future<Map<String, dynamic>> getEventDetails(int eventId) async {
    return (await _get('/magic-events/$eventId/')) as Map<String, dynamic>;
  }

  /// Parse matches from event detail, filtering to 1v1 only.
  List<SpicerackMatch> parseMatches(Map<String, dynamic> eventDetail) {
    final matches = <SpicerackMatch>[];
    final phases = (eventDetail['tournament_phases'] as List?) ?? [];

    for (final phase in phases) {
      final rounds =
          ((phase as Map<String, dynamic>)['rounds'] as List?) ?? [];

      for (final round in rounds) {
        final roundNumber =
            (round as Map<String, dynamic>)['round_number'] as int? ?? 0;
        if (roundNumber == 0) continue;

        final roundMatches = (round['matches'] as List?) ?? [];

        for (final match in roundMatches) {
          final rels = ((match as Map<String, dynamic>)[
                  'player_match_relationships'] as List?) ??
              [];

          final players = <SpicerackMatchPlayer>[];
          for (final rel in rels) {
            final ues =
                (rel as Map<String, dynamic>)['user_event_status'] as Map?;
            if (ues == null) continue;
            final user = ues['user'] as Map?;
            if (user == null) continue;

            players.add(SpicerackMatchPlayer(
              userId: user['id'] as int? ?? 0,
              name: user['best_identifier'] as String? ?? 'Unknown',
              gamesWon: rel['games_won'] as int? ?? 0,
            ));
          }

          if (players.length == 2) {
            matches.add(SpicerackMatch(
              id: match['id'] as int,
              roundNumber: roundNumber,
              players: players,
            ));
          }
        }
      }
    }
    return matches;
  }

  /// Parse decklist info from registrations response.
  Map<int, SpicerackDecklist> parseDecklists(
      List<Map<String, dynamic>> registrationsJson) {
    final map = <int, SpicerackDecklist>{};
    for (final reg in registrationsJson) {
      final dl = reg['decklist'];
      if (dl == null || dl is! Map) continue;
      final userId = (reg['user'] as Map?)?['id'] as int?;
      if (userId == null) continue;

      map[userId] = SpicerackDecklist(
        id: dl['id'] as int? ?? 0,
        name: dl['name'] as String? ?? 'Unknown Deck',
        archetype: dl['archetype'] as String?,
        moxfieldPublicId: dl['moxfield_public_id'] as String?,
      );
    }
    return map;
  }
}

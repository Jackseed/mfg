import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Single resolved Scryfall card, holding only what we need to display an
/// avatar in the bottom sheet typeahead.
class ScryfallCardResult {
  final String name;
  final String? artCropUrl;
  final String? smallUrl;
  final String? setCode;

  const ScryfallCardResult({
    required this.name,
    this.artCropUrl,
    this.smallUrl,
    this.setCode,
  });

  factory ScryfallCardResult.fromJson(Map<String, dynamic> data) {
    String? art;
    String? small;
    final images = data['image_uris'] as Map<String, dynamic>?;
    if (images != null) {
      art = images['art_crop'] as String?;
      small = images['small'] as String? ?? images['normal'] as String?;
    } else {
      final faces = data['card_faces'] as List?;
      if (faces != null && faces.isNotEmpty) {
        final face = faces.first as Map<String, dynamic>;
        final faceImages = face['image_uris'] as Map<String, dynamic>?;
        art = faceImages?['art_crop'] as String?;
        small = faceImages?['small'] as String? ?? faceImages?['normal'] as String?;
      }
    }
    return ScryfallCardResult(
      name: data['name'] as String? ?? '',
      artCropUrl: art,
      smallUrl: small,
      setCode: data['set'] as String?,
    );
  }
}

/// Typeahead against Scryfall `/cards/autocomplete` + name resolution via
/// `/cards/named`.
///
/// Usage:
/// ```
/// final svc = ScryfallCardSearchService();
/// final names = await svc.autocomplete('thou'); // List<String>
/// final card = await svc.fetchByName(names.first);
/// // card.artCropUrl → use as deck avatar
/// ```
///
/// Autocomplete results are debounced client-side (`suggestionsDebounced`) so
/// callers can wire `onChanged` straight into the service without managing
/// timers.
class ScryfallCardSearchService {
  ScryfallCardSearchService({
    http.Client? client,
    Duration debounce = const Duration(milliseconds: 300),
  })  : _client = client ?? http.Client(),
        _debounce = debounce;

  static const _base = 'https://api.scryfall.com';
  static const _userAgent = 'MFGApp/1.0';

  final http.Client _client;
  final Duration _debounce;

  // Caches.
  final Map<String, List<String>> _autocompleteCache = {};
  final Map<String, ScryfallCardResult?> _nameCache = {};

  // Debounce state.
  Timer? _debounceTimer;
  String? _pendingQuery;
  Completer<List<String>>? _pendingCompleter;

  /// Returns up to 20 card-name completions for [query]. Raw call — no debounce.
  Future<List<String>> autocomplete(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final cached = _autocompleteCache[q];
    if (cached != null) return cached;

    final uri = Uri.parse(
      '$_base/cards/autocomplete?q=${Uri.encodeComponent(q)}',
    );
    try {
      final res = await _client.get(uri, headers: {'User-Agent': _userAgent});
      if (res.statusCode != 200) return [];
      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = (data['data'] as List?)?.cast<String>() ?? const <String>[];
      _autocompleteCache[q] = items;
      return items;
    } catch (_) {
      return [];
    }
  }

  /// Debounced version of [autocomplete]. Successive calls within the debounce
  /// window share a single completer — the last query wins.
  Future<List<String>> suggestionsDebounced(String query) {
    _pendingQuery = query;
    _pendingCompleter ??= Completer<List<String>>();
    final completer = _pendingCompleter!;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () async {
      final q = _pendingQuery ?? '';
      _pendingCompleter = null;
      try {
        final results = await autocomplete(q);
        if (!completer.isCompleted) completer.complete(results);
      } catch (e) {
        if (!completer.isCompleted) completer.complete(const []);
      }
    });

    return completer.future;
  }

  /// Resolves a full card payload (including image URIs) by exact name. Uses
  /// Scryfall's `/cards/named?exact=`. Returns null on 404 / network error.
  Future<ScryfallCardResult?> fetchByName(String name) async {
    final key = name.trim();
    if (key.isEmpty) return null;
    if (_nameCache.containsKey(key)) return _nameCache[key];

    final uri =
        Uri.parse('$_base/cards/named?exact=${Uri.encodeComponent(key)}');
    try {
      final res = await _client.get(uri, headers: {'User-Agent': _userAgent});
      if (res.statusCode != 200) {
        _nameCache[key] = null;
        return null;
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final card = ScryfallCardResult.fromJson(data);
      _nameCache[key] = card;
      return card;
    } catch (_) {
      _nameCache[key] = null;
      return null;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _client.close();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Resolves a Scryfall art_crop image URL from a deck archetype name.
///
/// Strategy:
/// 1. Normalize the archetype (lowercase, strip parentheticals, color prefixes, etc.)
/// 2. Try to match against known archetype → key card mappings
/// 3. Fall back to a direct Scryfall search on the cleaned name
class ArchetypeCardResolver {
  /// Cache: cleaned archetype → art_crop URL
  static final Map<String, String?> _cache = {};

  /// All known archetype keywords, sorted alphabetically.
  static List<String> get knownArchetypes {
    final keys = _keywordToCard.keys.toList()..sort();
    return keys;
  }

  // ---------------------------------------------------------------------------
  // Known archetype keyword → Scryfall card name
  // Add more as needed. Keys are lowercase substrings to match against the
  // normalized archetype name.
  // ---------------------------------------------------------------------------
  static const _keywordToCard = <String, String>{
    // Legacy
    'death and taxes': 'Thalia, Guardian of Thraben',
    'delver': 'Delver of Secrets',
    'reanimator': 'Reanimate',
    'dredge': 'Golgari Grave-Troll',
    'led dredge': 'Lion\'s Eye Diamond',
    'sneak and show': 'Show and Tell',
    'sneak attack': 'Sneak Attack',
    'show and tell': 'Show and Tell',
    'storm': 'Tendrils of Agony',
    'elves': 'Green Sun\'s Zenith',
    'lands': 'Dark Depths',
    'depths': 'Dark Depths',
    'painter': 'Painter\'s Servant',
    'enchantress': 'Sterling Grove',
    'burn': 'Lightning Bolt',
    'aggro loam': 'Life from the Loam',
    'loam': 'Life from the Loam',
    'cradle control': 'Gaea\'s Cradle',
    'infect': 'Inkmoth Nexus',
    'cephalid breakfast': 'Cephalid Illusionist',
    'maverick': 'Knight of the Reliquary',
    'miracles': 'Terminus',
    'food chain': 'Food Chain',
    'high tide': 'High Tide',
    '8-cast': 'Thought Monitor',
    'urza': 'Urza\'s Saga',
    'belcher': 'Goblin Charbelcher',
    'charbelcher': 'Goblin Charbelcher',
    'nic fit': 'Veteran Explorer',
    'pox': 'Smallpox',
    'stax': 'Smokestack',
    'solidarity': 'High Tide',
    'loam pox': 'Life from the Loam',
    'omni-tell': 'Omniscience',
    'omnitell': 'Omniscience',
    'omni tell': 'Omniscience',
    'stiflenought': 'Phyrexian Dreadnought',
    'dimir tempo': 'Delver of Secrets',
    'the epic storm': 'Tendrils of Agony',
    'epic storm': 'Tendrils of Agony',
    'tes': 'Tendrils of Agony',
    'esper vial': 'Aether Vial',
    'goblins': 'Goblin Lackey',
    'post': 'Cloudpost',
    'cloudpost': 'Cloudpost',
    'hogaak': 'Hogaak, Arisen Necropolis',
    'turbo depths': 'Dark Depths',
    'mono white': 'Thalia, Guardian of Thraben',
    'prison': 'Chalice of the Void',
    'chalice': 'Chalice of the Void',
    'imperial painter': 'Painter\'s Servant',
    'sneak show': 'Show and Tell',
    // Modern
    'tron': 'Urza\'s Tower',
    'amulet': 'Amulet of Vigor',
    'titan': 'Primeval Titan',
    'valakut': 'Valakut, the Molten Pinnacle',
    'hammer time': 'Colossus Hammer',
    'hammer': 'Colossus Hammer',
    'affinity': 'Cranial Plating',
    'scales': 'Hardened Scales',
    'living end': 'Living End',
    'cascade crash': 'Violent Outburst',
    'yawgmoth': 'Yawgmoth, Thran Physician',
    'devoted druid': 'Devoted Druid',
    'heliod': 'Heliod, Sun-Crowned',
    'crashing footfalls': 'Crashing Footfalls',
    'rhinos': 'Crashing Footfalls',
    'murktide': 'Murktide Regent',
    'ragavan': 'Ragavan, Nimble Pilferer',
    'omnath': 'Omnath, Locus of Creation',
    'elementals': 'Risen Reef',
    'jund': 'Bloodbraid Elf',
    'deathshadow': 'Death\'s Shadow',
    'shadow': 'Death\'s Shadow',
    'grixis shadow': 'Death\'s Shadow',
    // Pioneer / Standard
    'greasefang': 'Greasefang, Okiba Boss',
    'winota': 'Winota, Joiner of Forces',
    'lotus field': 'Lotus Field',
    'phoenix': 'Arclight Phoenix',
    'arclight': 'Arclight Phoenix',
    'spirits': 'Mausoleum Wanderer',
    'humans': 'Champion of the Parish',
    'copycat': 'Felidar Guardian',
    'devotion': 'Nykthos, Shrine to Nyx',
    'nykthos': 'Nykthos, Shrine to Nyx',
    'atraxa': 'Atraxa, Grand Unifier',
    'sheoldred': 'Sheoldred, the Apocalypse',
    'fable': 'Fable of the Mirror-Breaker',
    // Vintage
    'workshop': 'Mishra\'s Workshop',
    'bazaar': 'Bazaar of Baghdad',
    'doomsday': 'Doomsday',
    'oath': 'Oath of Druids',
    'paradoxical outcome': 'Paradoxical Outcome',
    'paradoxical': 'Paradoxical Outcome',
    // Pauper
    'boros synthesizer': 'Experimental Synthesizer',
    'synthesizer': 'Experimental Synthesizer',
    'faeries': 'Spellstutter Sprite',
    'flicker tron': 'Urza\'s Tower',
    'walls': 'Overgrown Battlement',
  };

  /// Color/strategy words to strip from the archetype before key matching.
  static const _stripWords = [
    'mono white', 'mono blue', 'mono black', 'mono red', 'mono green',
    'mono-white', 'mono-blue', 'mono-black', 'mono-red', 'mono-green',
    'five color', '5 color', 'four color', '4 color', 'three color',
    // Guilds
    'azorius', 'dimir', 'rakdos', 'gruul', 'selesnya',
    'orzhov', 'izzet', 'golgari', 'boros', 'simic',
    // Shards / Wedges
    'esper', 'grixis', 'jund', 'naya', 'bant',
    'mardu', 'temur', 'abzan', 'jeskai', 'sultai',
    // Strategy suffixes
    ' aggro', ' control', ' midrange', ' combo', ' tempo', ' prison', ' toolbox',
  ];

  /// Resolves the best Scryfall art_crop URL for [archetype].
  /// Returns null if nothing is found.
  static Future<String?> resolve(String archetype) async {
    final normalized = _normalize(archetype);
    if (normalized.isEmpty) return null;

    if (_cache.containsKey(normalized)) return _cache[normalized];

    // 1. Try known keyword mapping
    String? cardName;
    for (final entry in _keywordToCard.entries) {
      if (normalized.contains(entry.key)) {
        cardName = entry.value;
        break;
      }
    }

    // 2. Fall back to Scryfall search on cleaned name
    cardName ??= normalized;

    final url = Uri.parse(
      'https://api.scryfall.com/cards/search'
      '?q=${Uri.encodeComponent(cardName)}&unique=art&order=released&dir=asc',
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'MFGApp/1.0'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final cards = data['data'] as List?;
        if (cards != null && cards.isNotEmpty) {
          final first = cards.first as Map<String, dynamic>;
          String? img = (first['image_uris'] as Map?)?['art_crop'] as String?;
          if (img == null) {
            final faces = first['card_faces'] as List?;
            if (faces != null && faces.isNotEmpty) {
              img = ((faces.first as Map)['image_uris'] as Map?)?['art_crop']
                  as String?;
            }
          }
          _cache[normalized] = img;
          return img;
        }
      }
    } catch (_) {
      // Network error — silently return null
    }

    _cache[normalized] = null;
    return null;
  }

  /// Normalize: lowercase, strip parentheticals, strip color/strategy words,
  /// strip leading/trailing dashes.
  static String _normalize(String archetype) {
    var s = archetype.toLowerCase();
    // Remove anything in parentheses: "(Yorion)", "(Lurrus)", etc.
    s = s.replaceAll(RegExp(r'\(.*?\)'), '');
    // Remove "- Something" color suffixes
    s = s.replaceAll(RegExp(r'\s*-\s*.*'), '');
    // Strip known color/strategy words
    for (final word in _stripWords) {
      s = s.replaceAll(word, '');
    }
    // Clean up whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

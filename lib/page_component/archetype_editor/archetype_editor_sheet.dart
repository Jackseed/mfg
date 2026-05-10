import 'dart:async';
import '/backend/backend.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/spicerack/archetype_card_resolver.dart';
import '/backend/spicerack/archetype_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Opens the archetype/deck editor as a modal bottom sheet.
/// Awaits sheet dismissal, then calls [onSaved] if the user saved changes.
Future<void> showArchetypeEditor(
  BuildContext context,
  DecksRecord deck, {
  VoidCallback? onSaved,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ArchetypeEditorSheet(deck: deck),
  );
  if (saved == true) onSaved?.call();
}

class ArchetypeEditorSheet extends StatefulWidget {
  const ArchetypeEditorSheet({Key? key, required this.deck}) : super(key: key);
  final DecksRecord deck;

  @override
  State<ArchetypeEditorSheet> createState() => _ArchetypeEditorSheetState();
}

class _ArchetypeEditorSheetState extends State<ArchetypeEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _archetypeController;
  late TextEditingController _moxfieldController;
  late TextEditingController _iconController;

  List<_ArchetypeSuggestion> _suggestions = [];
  String? _previewUrl;
  String? _previewCardName;
  bool _searching = false;
  bool _searchDone = false;

  List<({String name, String? url})> _iconSuggestions = [];
  bool _iconLoading = false;
  bool _iconNoResult = false;
  Timer? _iconDebounce;

  DecksRecord? _selectedTemplate;
  late Future<List<DecksRecord>> _existingDecksFuture;

  bool _saving = false;

  final _archetypeService = ArchetypeService();

  @override
  void initState() {
    super.initState();
    final deck = widget.deck;
    _nameController = TextEditingController(text: deck.name);
    _archetypeController = TextEditingController(
      text: deck.avatarName.isNotEmpty ? deck.avatarName : '',
    );
    _moxfieldController = TextEditingController(text: deck.moxfieldUrl);
    _iconController = TextEditingController();

    _previewUrl =
        (deck.avatarUrl.isNotEmpty && deck.avatarUrl.startsWith('http'))
            ? deck.avatarUrl
            : null;
    _previewCardName =
        deck.avatarCardName.isNotEmpty ? deck.avatarCardName : null;

    _existingDecksFuture = deck.crewId.isNotEmpty
        ? queryDecksRecordOnce(
            queryBuilder: (q) =>
                q.where('crewId', isEqualTo: deck.crewId),
          ).then((all) => all
              .where((d) =>
                  deck.crewmateId.isEmpty || d.crewmateId == deck.crewmateId)
              .toList())
        : Future.value(<DecksRecord>[]);
  }

  @override
  void dispose() {
    _iconDebounce?.cancel();
    _nameController.dispose();
    _archetypeController.dispose();
    _moxfieldController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<List<_ArchetypeSuggestion>> _fetchSuggestions(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return [];

    final remote = await _archetypeService.search(trimmed, limit: 8);
    final seen = <String>{};
    final merged = <_ArchetypeSuggestion>[];
    for (final a in remote) {
      final key =
          a.nameLower.isNotEmpty ? a.nameLower : a.name.toLowerCase();
      if (seen.add(key)) merged.add(_ArchetypeSuggestion.fromRecord(a));
    }

    if (merged.length < 8) {
      final lower = trimmed.toLowerCase();
      for (final k in ArchetypeCardResolver.knownArchetypes) {
        if (!k.contains(lower)) continue;
        if (seen.add(k)) {
          merged.add(_ArchetypeSuggestion.fromStatic(k));
          if (merged.length >= 8) break;
        }
      }
    }
    return merged;
  }

  String _toTitleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  Future<void> _save() async {
    final deck = widget.deck;
    final deckNameValue = _nameController.text.trim();
    final archetypeName = _archetypeController.text.trim();
    final moxfield = _moxfieldController.text.trim();
    final deckRef = deck.reference;
    final savedPreviewUrl = _previewUrl;
    final savedPreviewCardName = _previewCardName;
    final savedTemplateRef = _selectedTemplate?.reference;
    final oldDeckId = deck.deckId;
    final newDeckId = _selectedTemplate?.deckId ?? '';

    setState(() => _saving = true);

    DocumentReference? archetypeRef;
    if (archetypeName.isNotEmpty) {
      try {
        final archetype =
            await _archetypeService.findOrCreate(archetypeName);
        archetypeRef = archetype.reference;
      } catch (_) {}
    }

    try {
      await deckRef.update({
        if (deckNameValue.isNotEmpty) 'name': deckNameValue,
        'avatarName': archetypeName.isNotEmpty ? archetypeName : '',
        if (archetypeRef != null) 'archetypeRef': archetypeRef,
        if (savedPreviewUrl != null) 'avatarUrl': savedPreviewUrl,
        if (savedPreviewCardName != null)
          'avatarCardName': savedPreviewCardName,
        if (moxfield.isNotEmpty) 'moxfieldUrl': moxfield,
        if (savedTemplateRef != null) 'templateRef': savedTemplateRef,
        if (savedTemplateRef != null && newDeckId.isNotEmpty)
          'deckId': newDeckId,
      });
    } catch (_) {}

    final shouldMerge = savedTemplateRef != null &&
        oldDeckId.isNotEmpty &&
        newDeckId.isNotEmpty &&
        oldDeckId != newDeckId;
    if (shouldMerge) {
      try {
        final db = FirebaseFirestore.instance;
        final matchupsSnap = await db
            .collection('matchups')
            .where('deckIds', arrayContains: oldDeckId)
            .get();
        final gamesSnap = await db
            .collection('games')
            .where('deckIds', arrayContains: oldDeckId)
            .get();
        final batch = db.batch();

        for (final doc in matchupsSnap.docs) {
          final data = doc.data();
          final deckIds =
              List<String>.from(data['deckIds'] as List? ?? []);
          final i = deckIds.indexOf(oldDeckId);
          if (i >= 0) deckIds[i] = newDeckId;
          final rawScores = data['scores'];
          final scores = rawScores is List
              ? rawScores
                  .cast<Map<String, dynamic>>()
                  .map((s) => {
                        ...s,
                        if (s['deckId'] == oldDeckId) 'deckId': newDeckId,
                      })
                  .toList()
              : null;
          batch.update(doc.reference, {
            'deckIds': deckIds,
            if (scores != null) 'scores': scores,
          });
        }

        for (final doc in gamesSnap.docs) {
          final data = doc.data();
          final deckIds =
              List<String>.from(data['deckIds'] as List? ?? []);
          final i = deckIds.indexOf(oldDeckId);
          if (i >= 0) deckIds[i] = newDeckId;
          batch.update(doc.reference, {'deckIds': deckIds});
        }

        await batch.commit();
        debugPrint('[DeckMerge] reassigned '
            '${matchupsSnap.docs.length} matchups + '
            '${gamesSnap.docs.length} games '
            'from $oldDeckId → $newDeckId');
      } catch (e) {
        debugPrint('[DeckMerge] error: $e');
      }
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Deck name ──────────────────────────────────────────────────
            Text(
              'Nom du deck',
              style: theme.bodySmall.override(
                fontFamily: 'Noto Sans',
                color: theme.primaryText.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: theme.primaryText,
                fontFamily: 'Noto Sans',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: widget.deck.name,
                hintStyle: TextStyle(
                  color: theme.primaryText.withOpacity(0.4),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: theme.primaryText.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),

            // ── Template chips (existing decks for this crewmate) ──────────
            FutureBuilder<List<DecksRecord>>(
              future: _existingDecksFuture,
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                bool isPlaceholder(String name) {
                  final lower = name.toLowerCase().trim();
                  return lower.isEmpty ||
                      lower == 'unknown' ||
                      lower == 'unknown deck' ||
                      lower.endsWith("'s deck") ||
                      lower.endsWith("s deck");
                }

                final seen = <String>{};
                final others = (snap.data!
                      ..sort((a, b) => a.name.compareTo(b.name)))
                    .where((d) =>
                        d.reference.id != widget.deck.reference.id &&
                        !isPlaceholder(d.name) &&
                        seen.add(d.name))
                    .toList();
                if (others.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: others.map((d) {
                        final isSelected =
                            _selectedTemplate?.reference.id ==
                                d.reference.id;
                        return ActionChip(
                          label: Text(
                            d.name,
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              fontSize: 12,
                              color: isSelected
                                  ? theme.primary
                                  : Colors.white,
                            ),
                          ),
                          backgroundColor: isSelected
                              ? theme.tertiary
                              : const Color(0xFF3A3A42),
                          side: BorderSide(
                            color: isSelected
                                ? theme.tertiary
                                : const Color(0xFF5A5A65),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          onPressed: () {
                            _nameController.text = d.name;
                            _archetypeController.text = d.avatarName;
                            _moxfieldController.text = d.moxfieldUrl;
                            setState(() {
                              _selectedTemplate = d;
                              _previewUrl =
                                  d.avatarUrl.isNotEmpty &&
                                          d.avatarUrl.startsWith('http')
                                      ? d.avatarUrl
                                      : null;
                              _previewCardName =
                                  d.avatarCardName.isNotEmpty
                                      ? d.avatarCardName
                                      : null;
                              _searchDone = _previewUrl != null;
                              _suggestions = [];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),

            // ── Archetype ──────────────────────────────────────────────────
            const SizedBox(height: 16),
            Text(
              'Archétype',
              style: theme.bodySmall.override(
                fontFamily: 'Noto Sans',
                color: theme.primaryText.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _archetypeController,
                    onChanged: (val) async {
                      setState(() {
                        _previewUrl = null;
                        _searchDone = false;
                      });
                      final found = await _fetchSuggestions(val);
                      if (!mounted) return;
                      if (_archetypeController.text != val) return;
                      setState(() => _suggestions = found);
                    },
                    style: TextStyle(
                      color: theme.primaryText,
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ex: Reanimator, Loam Pox...',
                      hintStyle: TextStyle(
                        color: theme.primaryText.withOpacity(0.4),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: theme.primaryText.withOpacity(0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (_searching || _saving)
                      ? null
                      : () async {
                          setState(() {
                            _searching = true;
                            _searchDone = false;
                          });
                          final term = _archetypeController.text.trim();
                          final url =
                              await ArchetypeCardResolver.resolve(term);
                          if (!mounted) return;
                          setState(() {
                            _previewUrl = url;
                            _previewCardName = url != null ? term : null;
                            _searching = false;
                            _searchDone = true;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _searching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Chercher',
                          style: TextStyle(
                              fontFamily: 'Noto Sans', fontSize: 13)),
                ),
              ],
            ),

            // ── Archetype suggestion chips ──────────────────────────────────
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _suggestions.map((s) {
                  final label = s.displayName.isNotEmpty
                      ? s.displayName
                      : _toTitleCase(s.name);
                  return ActionChip(
                    label: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF3A3A42),
                    side: const BorderSide(color: Color(0xFF5A5A65)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    onPressed: () async {
                      _archetypeController.text = label;
                      setState(() {
                        _suggestions = [];
                        _searching = true;
                        _searchDone = false;
                        _previewUrl = null;
                      });
                      String? url = s.avatarUrl;
                      String? cardName = s.avatarCardName;
                      if (url == null || url.isEmpty) {
                        url = await ArchetypeCardResolver.resolve(s.name);
                        cardName = url != null ? s.name : null;
                      }
                      if (!mounted) return;
                      setState(() {
                        _previewUrl = url;
                        _previewCardName = cardName;
                        _searching = false;
                        _searchDone = true;
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            // ── Card preview ───────────────────────────────────────────────
            if (_previewUrl != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: CachedNetworkImage(
                      imageUrl: _previewUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF2A2A2F),
                        child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 24,
                            color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Image trouvée !',
                      style: theme.bodySmall.override(
                        fontFamily: 'Noto Sans',
                        color: const Color(0xFF2ECC71),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_searchDone && !_searching) ...[
              const SizedBox(height: 12),
              Text(
                'Aucune image trouvée. Tu peux quand même sauvegarder le nom.',
                style: theme.bodySmall.override(
                  fontFamily: 'Noto Sans',
                  color: const Color(0xFFF1C40F),
                  fontSize: 12,
                ),
              ),
            ],

            // ── Moxfield link ──────────────────────────────────────────────
            const SizedBox(height: 16),
            Text(
              'Lien Moxfield (optionnel)',
              style: theme.bodySmall.override(
                fontFamily: 'Noto Sans',
                color: theme.primaryText.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _moxfieldController,
              keyboardType: TextInputType.url,
              style: TextStyle(
                color: theme.primaryText,
                fontFamily: 'Noto Sans',
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'https://www.moxfield.com/decks/...',
                hintStyle: TextStyle(
                  color: theme.primaryText.withOpacity(0.4),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: theme.primaryText.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),

            // ── Scryfall icon typeahead ─────────────────────────────────────
            const SizedBox(height: 16),
            Text(
              'Icône (carte Scryfall — optionnel)',
              style: theme.bodySmall.override(
                fontFamily: 'Noto Sans',
                color: theme.primaryText.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _iconController,
              style: TextStyle(
                color: theme.primaryText,
                fontFamily: 'Noto Sans',
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'ex: Thoughtseize, Ragavan...',
                hintStyle: TextStyle(
                  color: theme.primaryText.withOpacity(0.4),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: theme.primaryText.withOpacity(0.07),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                suffixIcon: _iconLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primaryText.withOpacity(0.5),
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: (val) {
                _iconDebounce?.cancel();
                final query = val.trim();
                if (query.length < 2) {
                  setState(() {
                    _iconSuggestions = [];
                    _iconLoading = false;
                    _iconNoResult = false;
                  });
                  return;
                }
                setState(() {
                  _iconLoading = true;
                  _iconNoResult = false;
                });
                _iconDebounce =
                    Timer(const Duration(milliseconds: 600), () async {
                  if (!mounted) return;
                  final result =
                      await ScryfallIlluByNameCall.call(cardName: query);
                  if (!mounted) return;
                  final names =
                      ScryfallIlluByNameCall.names(result.jsonBody) ?? [];
                  final urls =
                      ScryfallIlluByNameCall.images(result.jsonBody) ?? [];
                  final suggestions = List.generate(
                    names.length.clamp(0, 6),
                    (i) => (
                      name: '${names[i]}',
                      url: i < urls.length
                          ? (urls[i] as Object?)?.toString()
                          : null,
                    ),
                  );
                  setState(() {
                    _iconSuggestions = suggestions;
                    _iconNoResult = suggestions.isEmpty;
                    _iconLoading = false;
                  });
                });
              },
            ),

            // ── Icon suggestion rows ────────────────────────────────────────
            if (_iconSuggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Column(
                children: _iconSuggestions.map((card) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _iconController.text = card.name;
                      setState(() {
                        _iconSuggestions = [];
                        if (card.url != null) {
                          _previewUrl = card.url;
                          _previewCardName = card.name;
                          _searchDone = true;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: card.url != null
                                ? Image.network(
                                    card.url!,
                                    width: 48,
                                    height: 34,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox(
                                            width: 48, height: 34),
                                  )
                                : Container(
                                    width: 48,
                                    height: 34,
                                    color: const Color(0xFF2A2A2F),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              card.name,
                              style: const TextStyle(
                                fontFamily: 'Noto Sans',
                                fontSize: 13,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            if (_iconNoResult && !_iconLoading) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.sentiment_dissatisfied_outlined,
                    size: 16,
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.4)),
                const SizedBox(width: 6),
                Text(
                  'Aucune carte trouvée',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context)
                        .primaryText
                        .withOpacity(0.5),
                  ),
                ),
              ]),
            ],

            // ── Save button ────────────────────────────────────────────────
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).tertiary,
                  foregroundColor: FlutterFlowTheme.of(context).primary,
                  disabledBackgroundColor: FlutterFlowTheme.of(context)
                      .primaryText
                      .withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      )
                    : const Text(
                        'Sauvegarder',
                        style: TextStyle(
                          fontFamily: 'Cinzel Decorative',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchetypeSuggestion {
  final String name;
  final String displayName;
  final String? avatarUrl;
  final String? avatarCardName;

  const _ArchetypeSuggestion({
    required this.name,
    required this.displayName,
    this.avatarUrl,
    this.avatarCardName,
  });

  factory _ArchetypeSuggestion.fromRecord(ArchetypesRecord rec) =>
      _ArchetypeSuggestion(
        name: rec.name,
        displayName: rec.name,
        avatarUrl: rec.hasAvatarUrl() && rec.avatarUrl.isNotEmpty
            ? rec.avatarUrl
            : null,
        avatarCardName:
            rec.hasAvatarCardName() && rec.avatarCardName.isNotEmpty
                ? rec.avatarCardName
                : null,
      );

  factory _ArchetypeSuggestion.fromStatic(String keyword) {
    final title = keyword
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return _ArchetypeSuggestion(name: keyword, displayName: title);
  }
}

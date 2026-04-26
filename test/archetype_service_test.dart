/// Pure-Dart tests for the deterministic helpers on [ArchetypeService].
///
/// These are the guarantees the rest of the app relies on:
///   • `slugify` collapses casing / whitespace / punctuation to a single
///     stable id, so two crews entering "Bant Control" and "bant control"
///     converge on the same archetype document.
///   • `normalize` is symmetric with the `nameLower` field used for
///     prefix-search on Firestore (`where('nameLower', ...)`).
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/backend/spicerack/archetype_service.dart';

void main() {
  group('ArchetypeService.normalize', () {
    test('lowercases + collapses whitespace + trims', () {
      expect(ArchetypeService.normalize('  Bant  Control  '), 'bant control');
      expect(ArchetypeService.normalize('GRIXIS\treanimator'),
          'grixis reanimator');
    });

    test('is a no-op on an already-normalized string', () {
      expect(ArchetypeService.normalize('bant control'), 'bant control');
    });

    test('empty input stays empty', () {
      expect(ArchetypeService.normalize(''), '');
      expect(ArchetypeService.normalize('   '), '');
    });
  });

  group('ArchetypeService.slugify', () {
    test('produces the same id regardless of casing or whitespace', () {
      expect(ArchetypeService.slugify('Bant Control'), 'bant-control');
      expect(ArchetypeService.slugify('  bant  control  '), 'bant-control');
      expect(ArchetypeService.slugify('BANT  CONTROL'), 'bant-control');
    });

    test('strips punctuation and leading/trailing hyphens', () {
      expect(ArchetypeService.slugify("5-Color Humans!"), '5-color-humans');
      expect(ArchetypeService.slugify("---edge case---"), 'edge-case');
    });

    test('accents and non-ASCII letters are stripped (conservative slug)', () {
      // The current implementation only keeps [a-z0-9]; accented chars map
      // to the hyphen class. We pin this behaviour so a future change is an
      // explicit decision.
      expect(ArchetypeService.slugify('Éphémère'), 'ph-m-re');
    });

    test('pure-punctuation input collapses to empty', () {
      expect(ArchetypeService.slugify('---'), '');
      expect(ArchetypeService.slugify('!!!'), '');
    });
  });
}

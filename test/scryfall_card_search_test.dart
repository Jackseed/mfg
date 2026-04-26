/// Pure-Dart tests for the Scryfall response parsing on
/// [ScryfallCardResult.fromJson]. No network calls — we feed the parser the
/// two shapes Scryfall actually returns (single-face cards and double-faced
/// cards where image_uris live under card_faces[0]).
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/backend/spicerack/scryfall_card_search_service.dart';

void main() {
  group('ScryfallCardResult.fromJson', () {
    test('reads art_crop + small from top-level image_uris', () {
      final card = ScryfallCardResult.fromJson({
        'name': 'Reanimate',
        'set': 'tmp',
        'image_uris': {
          'art_crop': 'https://cdn.example/rean-art.png',
          'small': 'https://cdn.example/rean-small.png',
          'normal': 'https://cdn.example/rean-normal.png',
        },
      });
      expect(card.name, 'Reanimate');
      expect(card.setCode, 'tmp');
      expect(card.artCropUrl, 'https://cdn.example/rean-art.png');
      // small takes precedence over normal.
      expect(card.smallUrl, 'https://cdn.example/rean-small.png');
    });

    test('falls back to normal when small is missing', () {
      final card = ScryfallCardResult.fromJson({
        'name': 'Foo',
        'image_uris': {
          'normal': 'https://cdn.example/foo-normal.png',
        },
      });
      expect(card.smallUrl, 'https://cdn.example/foo-normal.png');
      expect(card.artCropUrl, null);
    });

    test('reads images from card_faces[0] for transform cards', () {
      final card = ScryfallCardResult.fromJson({
        'name': 'Delver of Secrets // Insectile Aberration',
        'set': 'isd',
        'card_faces': [
          {
            'name': 'Delver of Secrets',
            'image_uris': {
              'art_crop': 'https://cdn.example/delver-art.png',
              'small': 'https://cdn.example/delver-small.png',
            },
          },
          {
            'name': 'Insectile Aberration',
            'image_uris': {
              'art_crop': 'https://cdn.example/abom-art.png',
            },
          },
        ],
      });
      expect(card.name, contains('Delver'));
      expect(card.artCropUrl, 'https://cdn.example/delver-art.png');
      expect(card.smallUrl, 'https://cdn.example/delver-small.png');
    });

    test('degrades gracefully when both image_uris and card_faces are missing',
        () {
      final card = ScryfallCardResult.fromJson({'name': 'No Images'});
      expect(card.name, 'No Images');
      expect(card.artCropUrl, null);
      expect(card.smallUrl, null);
    });

    test('empty card_faces list does not throw', () {
      final card = ScryfallCardResult.fromJson({
        'name': 'Broken',
        'card_faces': <Map<String, dynamic>>[],
      });
      expect(card.artCropUrl, null);
      expect(card.smallUrl, null);
    });
  });
}

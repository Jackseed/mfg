import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class ScryfallIlluByNameCall {
  static Future<ApiCallResponse> call({
    String? cardName = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Scryfall illu by name',
      // (name:"..." OR foreign:"...") searches English AND foreign names so
      // both "Reanimate" and "Réanimation" find the same card.
      // include_multilingual=true returns FR/EN/etc. printings.
      // unique=art deduplicates so we get one entry per distinct artwork.
      // Scryfall requires User-Agent + Accept headers on every request.
      apiUrl:
          'https://api.scryfall.com/cards/search?q=name%3A%22${Uri.encodeQueryComponent(cardName ?? '')}%22&include_multilingual=true&unique=art&order=edhrec',
      callType: ApiCallType.GET,
      headers: {
        'User-Agent': 'MFGApp/1.0',
        'Accept': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? names(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? images(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].image_uris.art_crop''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list);
  } catch (_) {
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar);
  } catch (_) {
    return isList ? '[]' : '{}';
  }
}

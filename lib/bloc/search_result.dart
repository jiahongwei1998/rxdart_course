import 'package:flutter/foundation.dart' show immutable;
import 'package:rxdart_course/models/thing.dart';

@immutable
abstract class SearchResult {}

@immutable
class SearchResultLoading implements SearchResult {
  const SearchResultLoading();
}

@immutable
class SearchResultNoResult implements SearchResult {
  const SearchResultNoResult();
}

@immutable
class SearchResultHasError implements SearchResult {
  const SearchResultHasError(Object error);
}

@immutable
class SearchResultWithResults implements SearchResult {
  final List<Thing> results;

  const SearchResultWithResults({required this.results});
}

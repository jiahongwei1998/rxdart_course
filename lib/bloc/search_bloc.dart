import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_course/bloc/api.dart';
import 'package:rxdart_course/bloc/search_result.dart';

@immutable
class SearchBloc {
  final Sink<String> search;
  final Stream<SearchResult?> results;

  void dispose() {
    search.close();
  }

  const SearchBloc._({required this.search, required this.results});

  factory SearchBloc({required Api api}) {
    final textChanges = BehaviorSubject<String>();
    final Stream<SearchResult?> results = textChanges
        .distinct()
        .debounceTime(const Duration(microseconds: 300))
        .switchMap((searchTerm) {
      if (searchTerm.isEmpty) {
        return Stream<SearchResult?>.value(null);
      } else {
        return Rx.fromCallable(() => api.search(searchTerm))
            .delay(const Duration(seconds: 1))
            .map((results) => results.isEmpty
                ? const SearchResultNoResult()
                : SearchResultWithResults(results: results))
            .startWith(const SearchResultLoading())
            .onErrorReturnWith(
                (error, stackTrace) => SearchResultHasError(error));
      }
    });

    return SearchBloc._(search: textChanges.sink, results: results);
  }
}

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paired_name_app/constants/filters.dart';
import 'package:paired_name_app/providers/storage_provider.dart';

class PairState {
  final WordPair currentPair;
  final List<WordPair> latestGeneratedPairs;
  final List<WordPair> bookmarkedPairs;

  PairState({
    required this.currentPair,
    required this.latestGeneratedPairs,
    required this.bookmarkedPairs,
  });

  // * For updating immutably
  PairState copyWith({
    WordPair? currentPair,
    List<WordPair>? latestGeneratedPairs,
    List<WordPair>? bookmarkedPairs,
  }) {
    return PairState(
      currentPair: currentPair ?? this.currentPair,
      latestGeneratedPairs: latestGeneratedPairs ?? this.latestGeneratedPairs,
      bookmarkedPairs: bookmarkedPairs ?? this.bookmarkedPairs,
    );
  }
}

final pairProvider = StateNotifierProvider<PairNotifier, PairState>((ref) {
  final storage = ref.watch(storageProvider.notifier);

  return PairNotifier(storage);
});

class PairNotifier extends StateNotifier<PairState> {
  final StorageNotifier storage;

  GlobalKey? latestGeneratedPairsListKey;

  PairNotifier(this.storage)
      : super(
          PairState(
            currentPair: WordPair.random(),
            latestGeneratedPairs: [],
            bookmarkedPairs: [],
          ),
        ) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeStorage();

    _loadStoredData();
    _filterStoredData();
  }

  Future<void> _initializeStorage() async {
    if (!storage.state) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !storage.state;
      });
    }
  }

  void _loadStoredData() {
    final storedBookmarkedPairs = storage.getData('bookmarkedPairs');
    if (storedBookmarkedPairs != null) {
      state = state.copyWith(
        bookmarkedPairs: (storedBookmarkedPairs as List)
            .map((pair) => WordPair(pair[0] as String, pair[1] as String))
            .toList(),
      );
    }
  }

  void _filterStoredData() {
    state = state.copyWith(
      bookmarkedPairs: state.bookmarkedPairs.where((pair) {
        // * Keep only the pairs that aren't blacklisted
        return !ConstantFilters.isBlacklistedWord(pair.first) &&
            !ConstantFilters.isBlacklistedWord(pair.second);
      }).toList(),
    );

    _overrideBookmarks();
  }

  void _overrideBookmarks() {
    storage.setData(
      'bookmarkedPairs',
      state.bookmarkedPairs.map((pair) => [pair.first, pair.second]).toList(),
    );
  }

  void generatePair() {
    WordPair newPair;

    // * Keep generating a new word pair until it is not blacklisted
    do {
      newPair = WordPair.random();
    } while (ConstantFilters.isBlacklistedWord(newPair.first) ||
        ConstantFilters.isBlacklistedWord(newPair.second) ||
        newPair == state.currentPair);

    final updatedPairs = [state.currentPair, ...state.latestGeneratedPairs];

    // * Don't keep more than 50 items
    if (updatedPairs.length > 50) {
      updatedPairs.removeLast();
    }

    // ? Animation is handled from here...
    final animatedList =
        latestGeneratedPairsListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    state = state.copyWith(
      currentPair: newPair,
      latestGeneratedPairs: updatedPairs,
    );
  }

  bool toggleBookmark([WordPair? pair]) {
    pair = pair ?? state.currentPair;
    bool toggledOn = false;

    if (state.bookmarkedPairs.contains(pair)) {
      removeFromBookmarks(pair);
    } else {
      addToBookmarks(pair);
      toggledOn = true;
    }

    return toggledOn;
  }

  void addToBookmarks(WordPair pair) {
    state = state.copyWith(bookmarkedPairs: [...state.bookmarkedPairs, pair]);

    _overrideBookmarks();
  }

  void removeFromBookmarks(WordPair pair) {
    state = state.copyWith(
      bookmarkedPairs: state.bookmarkedPairs.where((p) => p != pair).toList(),
    );

    _overrideBookmarks();
  }
}

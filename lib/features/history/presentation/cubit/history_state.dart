import 'package:flutter/foundation.dart';
import 'package:easy_calculator/features/history/domain/models/history_item.dart';

@immutable
class HistoryState {
  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<HistoryItem> items;
  final bool isLoading;
  final String? errorMessage;

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryState &&
        listEquals(other.items, items) &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(items), isLoading, errorMessage);
}

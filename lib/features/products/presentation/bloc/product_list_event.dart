import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

final class ProductListStarted extends ProductListEvent {
  const ProductListStarted();
}

final class ProductListRetryRequested extends ProductListEvent {
  const ProductListRetryRequested();
}

final class ProductListRefreshed extends ProductListEvent {
  const ProductListRefreshed({this.completer});

  /// Allows [RefreshIndicator] to keep its spinner until the request ends.
  final Completer<void>? completer;

  @override
  List<Object?> get props => [];
}

final class ProductListLoadMoreRequested extends ProductListEvent {
  const ProductListLoadMoreRequested();
}

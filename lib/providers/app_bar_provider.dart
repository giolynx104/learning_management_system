import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_bar_provider.g.dart';

@immutable
class AppBarState {
  final bool hideAppBar;

  const AppBarState({
    this.hideAppBar = false,
  });
}

@Riverpod(keepAlive: true)
class AppBarNotifier extends _$AppBarNotifier {
  @override
  AppBarState build() => const AppBarState();

  void hideAppBar() {
    state = const AppBarState(hideAppBar: true);
  }

  void showAppBar() {
    state = const AppBarState(hideAppBar: false);
  }
}

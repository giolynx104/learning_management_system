import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppBarState {
  final String title;
  final List<Widget>? actions;
  final bool showDefaultAppBar;
  final Widget? customAppBar;

  AppBarState({
    required this.title,
    this.actions,
    this.showDefaultAppBar = true,
    this.customAppBar,
  });

  AppBarState copyWith({
    String? title,
    List<Widget>? actions,
    bool? showDefaultAppBar,
    Widget? customAppBar,
  }) {
    return AppBarState(
      title: title ?? this.title,
      actions: actions ?? this.actions,
      showDefaultAppBar: showDefaultAppBar ?? this.showDefaultAppBar,
      customAppBar: customAppBar ?? this.customAppBar,
    );
  }
}

class AppBarNotifier extends StateNotifier<AppBarState> {
  AppBarNotifier() : super(AppBarState(title: 'Microsoft Teams'));

  void updateAppBar({
    String? title,
    List<Widget>? actions,
    bool? showDefaultAppBar,
    Widget? customAppBar,
  }) {
    state = state.copyWith(
      title: title,
      actions: actions,
      showDefaultAppBar: showDefaultAppBar,
      customAppBar: customAppBar,
    );
  }

  void reset() {
    state = AppBarState(title: 'Microsoft Teams');
  }
}

final appBarProvider = StateNotifierProvider<AppBarNotifier, AppBarState>((ref) {
  return AppBarNotifier();
}); 
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_bar_provider.g.dart';

@immutable
class AppBarState {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final bool? centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;

  const AppBarState({
    this.title = '',
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
  });

  AppBarState copyWith({
    String? title,
    List<Widget>? actions,
    bool? automaticallyImplyLeading,
    Widget? leading,
    bool? centerTitle,
    double? elevation,
    Color? backgroundColor,
    Color? foregroundColor,
    PreferredSizeWidget? bottom,
  }) {
    return AppBarState(
      title: title ?? this.title,
      actions: actions ?? this.actions,
      automaticallyImplyLeading: automaticallyImplyLeading ?? this.automaticallyImplyLeading,
      leading: leading ?? this.leading,
      centerTitle: centerTitle ?? this.centerTitle,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      bottom: bottom ?? this.bottom,
    );
  }
}

@Riverpod(keepAlive: true)
class AppBarNotifier extends _$AppBarNotifier {
  @override
  AppBarState build() => const AppBarState();

  void setAppBar({
    required String title,
    List<Widget>? actions,
    bool? automaticallyImplyLeading,
    Widget? leading,
    bool? centerTitle,
    double? elevation,
    Color? backgroundColor,
    Color? foregroundColor,
    PreferredSizeWidget? bottom,
  }) {
    state = state.copyWith(
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      bottom: bottom,
    );
  }

  void reset() {
    state = const AppBarState();
  }
} 
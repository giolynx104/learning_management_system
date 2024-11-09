import 'package:flutter/material.dart';

class TeamsModel {
  final String name;
  final Color color;

  TeamsModel({required this.name, required this.color});

  static List<TeamsModel> getTeams() {
    return [];
  }
}
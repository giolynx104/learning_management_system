import 'package:flutter/material.dart';

class TeamsModel {
  final String id;
  final String name;
  final Color color;

  TeamsModel({required this.id, required this.name, required this.color});

  static List<TeamsModel> getTeams() {
    return [];
  }

  String get classId => id.toString();
}
import 'package:flutter/material.dart';

class TeamsModel {
  final String name;
  final String initials;
  final String type;
  final Color color;

  TeamsModel({required this.name, required this.initials, required this.type, required this.color});

// Class to manage teams and provide them dynamically
  static List<TeamsModel> getTeams() {
    return [
      TeamsModel(name: "HUSTack", initials: "O", type: "Chung", color: Colors.orange),
      TeamsModel(name: "K66-Trường CNTT&TT", initials: "KC", type: "Chung", color: Colors.red),
      TeamsModel(name: "TUAN 20210901", initials: "T2", type: "Chung", color: Colors.green),
      TeamsModel(name: "Teams chạy deadline", initials: "Tc", type: "Riêng tư", color: Colors.blue),
      TeamsModel(name: "0224 HCI UX/UI", initials: "HU", type: "Riêng tư", color: Colors.purple),
      TeamsModel(name: "154043 - Android", initials: "A", type: "Chung", color: Colors.greenAccent),
      TeamsModel(name: "20241-C3-DBCL PM", initials: "CD", type: "Chung", color: Colors.teal),
      TeamsModel(name: "20241. IT4409. Web", initials: "IW", type: "Chung", color: Colors.pinkAccent),
    ];
}
}
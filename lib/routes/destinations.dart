import 'package:flutter/material.dart';

class Destination extends NavigationDestination {
  Destination({
    required String label,
    required IconData icon,
  }) : super(
          icon: Icon(icon),
          label: label,
        );
}

final List<Destination> studentDestinations = [
  Destination(
    icon: Icons.home,
    label: 'Home',
  ),
  Destination(
    icon: Icons.class_,
    label: 'Classes',
  ),
  Destination(
    icon: Icons.chat,
    label: 'Chat',
  ),
  Destination(
    icon: Icons.person,
    label: 'Profile',
  ),
];

final List<Destination> teacherDestinations = [
  Destination(
    icon: Icons.home,
    label: 'Home',
  ),
  Destination(
    icon: Icons.class_,
    label: 'Classes',
  ),
  Destination(
    icon: Icons.chat,
    label: 'Chat',
  ),
  Destination(
    icon: Icons.person,
    label: 'Profile',
  ),
];
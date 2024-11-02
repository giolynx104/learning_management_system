import 'package:flutter/material.dart';

class Destination {
  final String label;
  final IconData icon;
  final IconData onPressedIcon;
  const Destination({
    required this.label,
    required this.icon,
    required this.onPressedIcon });
  
}

const studentDestinations = [
  Destination(label: 'Home', icon: Icons.home_outlined, onPressedIcon: Icons.home_filled),
  Destination(label: 'Notification', icon: Icons.notifications_outlined, onPressedIcon: Icons.notifications_active),
  Destination(label: 'Class Registration', icon: Icons.class_outlined,onPressedIcon: Icons.class_sharp),
  Destination(label: 'Chat', icon: Icons.messenger_outline,onPressedIcon: Icons.messenger),
];
const teacherDestinations = [
  Destination(label: 'Home', icon: Icons.home_outlined, onPressedIcon: Icons.home_filled),
  Destination(label: 'Notification', icon: Icons.notifications_outlined, onPressedIcon: Icons.notifications_active),
  Destination(label: 'Class Management', icon: Icons.class_outlined,onPressedIcon: Icons.class_sharp),
  Destination(label: 'Chat', icon: Icons.messenger_outline,onPressedIcon: Icons.messenger),
];
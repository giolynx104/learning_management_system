import 'package:flutter/material.dart';

class TeamsItem extends StatelessWidget {
  final Color color;
  final IconData? icon;
  final String name;
  final VoidCallback? onMorePressed;

  const TeamsItem({
    required this.color,
    this.icon,
    required this.name,
    this.onMorePressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: icon != null ? Icon(icon, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: onMorePressed,
          ),
        ],
      ),
    );
  }
}

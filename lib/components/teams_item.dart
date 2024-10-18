import 'package:flutter/material.dart';

class TeamsExpansionItem extends StatefulWidget {
  final String name;
  final Color color;
  final IconData? icon;
  final VoidCallback onMorePressed;
 
  const TeamsExpansionItem({
    required this.name,
    required this.color,
    this.icon,
    required this.onMorePressed,

  });

  @override
  State<TeamsExpansionItem> createState() => _TeamsExpansionItemState();
}

class _TeamsExpansionItemState extends State<TeamsExpansionItem> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Row(
         mainAxisSize: MainAxisSize.min, 
        children: [
          Icon(
             isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
          ),
          CircleAvatar(
            backgroundColor: widget.color,
            child: widget.icon != null ? Icon(widget.icon, color: Colors.white) : null,
          ),
        ],
      ),
      title: Text(widget.name),
      trailing:IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: widget.onMorePressed, 
          ),
      onExpansionChanged: (bool expanded) {
            setState(() => isExpanded = expanded); 
          },
      children: [
        ListTile(
          title: Text('Chung'),
          
        ),
      ],
    );
  }
}
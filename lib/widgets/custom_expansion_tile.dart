import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onExpansionChanged;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.onExpansionChanged,
  });

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      leading: Icon(
        isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
      ),
      trailing: const SizedBox.shrink(),
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
        if (widget.onExpansionChanged != null) {
          widget.onExpansionChanged!();
        }
      },
      children: widget.children,
    );
  }
}

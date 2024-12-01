import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssignmentCard extends StatelessWidget {
  final String endTimeFormatted;
  final String name;
  final String? description;
  final VoidCallback? onTap;
  final Widget? trailing;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onViewResponse;

  const AssignmentCard({
    super.key,
    required this.endTimeFormatted,
    required this.name,
    this.description,
    this.onTap,
    this.trailing,
    this.onDelete,
    this.onEdit,
    this.onViewResponse,
  });

  @override
  Widget build(BuildContext context) {
    final endDateTime = DateFormat('HH:mm dd-MM-yyyy').parse(endTimeFormatted);
    final isOverdue = DateTime.now().isAfter(endDateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Due: $endTimeFormatted',
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
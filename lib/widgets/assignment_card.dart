import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssignmentCard extends StatelessWidget {
  final String endTimeFormatted;
  final String name;
  final String? description;
  final VoidCallback? onTap;
  final Function()? onEdit;
  final Function()? onDelete;
  final Function()? onViewResponse;
  final bool isTeacher;

  const AssignmentCard({
    super.key,
    required this.endTimeFormatted,
    required this.name,
    required this.isTeacher,
    this.description,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endDateTime = DateFormat('HH:mm dd-MM-yyyy').parse(endTimeFormatted);
    final isOverdue = DateTime.now().isAfter(endDateTime);

    return Card(
      elevation: 2,
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTeacher)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.primary,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                          case 'responses':
                            onViewResponse?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'responses',
                          child: Row(
                            children: [
                              Icon(Icons.assessment),
                              SizedBox(width: 8),
                              Text('View Responses'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 12),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: $endTimeFormatted',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
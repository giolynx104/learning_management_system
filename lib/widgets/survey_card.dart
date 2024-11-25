import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/models/survey.dart';

class SurveyCard extends StatelessWidget {
  final String endTimeFormatted;
  final String name;
  final String? description;
  final VoidCallback? onTap;
  final Widget? trailing;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onViewResponse;

  const SurveyCard({
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
    final theme = Theme.of(context);

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          endTimeFormatted,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (onDelete != null || onEdit != null || onViewResponse != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 24,
                        ),
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                            case 'view_response':
                              onViewResponse?.call();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit Assignment'),
                                ],
                              ),
                            ),
                          if (onViewResponse != null)
                            const PopupMenuItem(
                              value: 'view_response',
                              child: Row(
                                children: [
                                  Icon(Icons.assessment, size: 20),
                                  SizedBox(width: 12),
                                  Text('View Responses'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20),
                                  SizedBox(width: 12),
                                  Text('Delete Assignment'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 
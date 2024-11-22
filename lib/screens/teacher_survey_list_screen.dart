import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/models/survey.dart';

class TeacherSurveyListScreen extends ConsumerStatefulWidget {
  const TeacherSurveyListScreen({super.key});

  @override
  ConsumerState<TeacherSurveyListScreen> createState() => _TeacherSurveyListScreenState();
}

class _TeacherSurveyListScreenState extends ConsumerState<TeacherSurveyListScreen> {
  final List<TeacherSurvey> surveys = [
    TeacherSurvey(
      name: 'Survey 1',
      description: 'Description for Survey 1',
      file: 'path/to/survey1.docx',
      responseCount: 10,
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      className: 'Math 101',
    ),
    TeacherSurvey(
      name: 'Survey 2',
      description: 'Description for Survey 2',
      file: 'path/to/survey2.docx',
      responseCount: 5,
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      className: 'Science 101',
    ),
  ];

  List<TeacherSurvey> getUpcomingSurveys() {
    return surveys
        .where((survey) => survey.endTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<TeacherSurvey> getOverdueSurveys() {
    return surveys
        .where((survey) => survey.endTime.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appBarNotifierProvider.notifier).setAppBar(
        title: 'Manage Surveys',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.createSurvey),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    ref.read(appBarNotifierProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Survey Management'),
              Image.asset(
                'assets/images/HUST_white.png',
                height: 30,
                fit: BoxFit.contain,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(
              title: 'Active',
              surveys: getUpcomingSurveys(),
            ),
            SurveyTabContent(
              title: 'Expired',
              surveys: getOverdueSurveys(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(Routes.nestedCreateSurvey),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<TeacherSurvey> surveys;

  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: surveys.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final startTimeFormatted =
            DateFormat('HH:mm dd-MM-yyyy').format(survey.startTime);
        final endTimeFormatted =
            DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            survey.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'From: $startTimeFormatted',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'To: $endTimeFormatted',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
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
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
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
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            context.push(
                              Routes.nestedEditSurvey,
                              extra: TeacherSmallSurvey(
                                name: survey.name,
                                description: survey.description,
                                file: survey.file,
                                startTime: survey.startTime,
                                endTime: survey.endTime,
                              ),
                            );
                            break;
                          case 'delete':
                            // TODO: Implement delete
                            break;
                          case 'responses':
                            // TODO: Implement view responses
                            break;
                        }
                      },
                    ),
                  ],
                ),
                if (survey.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    survey.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Responses: ${survey.responseCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Class: ${survey.className}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TeacherSurvey {
  final String name;
  final String? description;
  final String? file;
  final int responseCount;
  final DateTime startTime;
  final DateTime endTime;
  final String className;

  TeacherSurvey({
    required this.name,
    this.description,
    this.file,
    required this.responseCount,
    required this.startTime,
    required this.endTime,
    required this.className,
  });
}

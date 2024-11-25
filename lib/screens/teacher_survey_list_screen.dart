import 'package:flutter/material.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:intl/intl.dart';  // Ensure this import is there
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';

class TeacherSurveyListScreen extends ConsumerStatefulWidget {
  final String classId;
  const TeacherSurveyListScreen({
    super.key,
    required this.classId,
  });

  @override
  TeacherSurveyListScreenState createState() => TeacherSurveyListScreenState();
}

class TeacherSurveyListScreenState extends ConsumerState<TeacherSurveyListScreen> {
  List<TeacherSurvey> surveys = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchSurveys() async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) {
      throw Exception('Not authenticated');
    }
    final surveyService = ref.read(surveyServiceProvider.notifier);

    try {
      final fetchedSurveys = await surveyService.getAllSurveys(
        token: authState.token!,
        classId: widget.classId, // Replace with actual class ID
      );

      final surveyList = fetchedSurveys.map((json) => TeacherSurvey.teacherFromJson(json as Map<String, dynamic>)).toList();

      setState(() {
        surveys = surveyList; // Assign the updated list to the state
      });
    } catch (e) {
      _showSnackBar('Error fetching surveys: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
  }

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

  Future<void> _deleteSurvey(String surveyId) async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }

      final surveyService = ref.read(surveyServiceProvider.notifier);

      // Call the deleteSurvey method
      await surveyService.deleteSurvey(
        token: authState.token!,
        survey_id: surveyId,
      );

      // Reload surveys after deletion
      await _fetchSurveys();

      // Show success snackbar
      _showSnackBar('Survey deleted successfully!');
    } catch (e) {
      // Show error snackbar
      _showSnackBar('Error deleting survey: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const SurveyTabBar(
            tabLabels: ['Active', 'Expired'],
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(
              title: 'Active',
              surveys: getUpcomingSurveys(),
              deleteSurvey: _deleteSurvey, // Pass delete function to the tab
              fetchSurveys: _fetchSurveys,
            ),
            SurveyTabContent(
              title: 'Expired',
              surveys: getOverdueSurveys(),
              deleteSurvey: _deleteSurvey, // Pass delete function to the tab
              fetchSurveys: _fetchSurveys,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.pushNamed(
              Routes.createSurveyName,
              pathParameters: {'classId': widget.classId},
            );

            if (result == true) {
              _fetchSurveys(); // Reload surveys
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<TeacherSurvey> surveys;
  final Future<void> Function(String surveyId) deleteSurvey;
  final Future<void> Function() fetchSurveys;
  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
    required this.deleteSurvey,
    required this.fetchSurveys,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: surveys.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final endTimeFormatted = DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);

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
                            endTimeFormatted,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            survey.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                              Text('Delete', style: TextStyle(color: Colors.red)),
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
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            final result = await context.pushNamed(
                              Routes.editSurveyName,
                              pathParameters: {'surveyId': survey.id},
                              extra: survey,
                            );

                            if (result == true) {
                              fetchSurveys(); // Reload surveys after editing
                            }
                            break;
                          case 'delete':
                            await deleteSurvey(survey.id);
                            break;
                          case 'responses':
                            context.pushNamed(
                              Routes.responseSurveyName,
                              pathParameters: {'surveyId': survey.id},
                            );
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class SurveyTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabLabels;

  const SurveyTabBar({
    super.key,
    required this.tabLabels,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: tabLabels.map((label) => Tab(text: label)).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

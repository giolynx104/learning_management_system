import 'package:flutter/material.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:intl/intl.dart';  // Ensure this import is there
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/widgets/survey_tab_bar.dart';
import 'package:learning_management_system/widgets/survey_card.dart';


class StudentSurveyListScreen extends ConsumerStatefulWidget {
  final String classId;
  const StudentSurveyListScreen({
    super.key,
    required this.classId,
  });

  @override
  StudentSurveyListScreenState createState() => StudentSurveyListScreenState();
}

class StudentSurveyListScreenState extends ConsumerState<StudentSurveyListScreen> {
  List<Survey> surveys = [];

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

      print('Fetched Surveys: $fetchedSurveys');

// Convert fetched data to `Survey` objects first
      final surveyList = fetchedSurveys.map((json) => Survey.fromJson(json as Map<String, dynamic>)).toList();

      try {
        for (var survey in surveyList) {
          final isSubmitted = await surveyService.checkSubmissionStatus(
            token: authState.token!,
            assignmentId: survey.id,
          );
          survey.isSubmitted = isSubmitted;
        }
      }catch (e) {
        print('Error updating surveys: $e');}

      print('Updated Fetched Surveys: $surveyList');

      setState(() {
        surveys = surveyList; // Assign the updated list to the state
      });

    } catch (e) {
      print('Error fetching surveys: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
  }

  List<Survey> getUpcomingSurveys() {
    return surveys
        .where((survey) => survey.endTime.isAfter(DateTime.now()) && !survey.isSubmitted)
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<Survey> getOverdueSurveys() {
    return surveys
        .where((survey) => survey.endTime.isBefore(DateTime.now()) && !survey.isSubmitted)
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<Survey> getCompletedSurveys() {
    return surveys
        .where((survey) => survey.isSubmitted)
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignment List'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const SurveyTabBar(
            tabLabels: ['Upcoming', 'Overdue', 'Completed'],
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(
              title: 'Upcoming',
              surveys: getUpcomingSurveys(),
            ),
            SurveyTabContent(
              title: 'Overdue',
              surveys: getOverdueSurveys(),
            ),
            SurveyTabContent(
              title: 'Completed',
              surveys: getCompletedSurveys(),
            ),
          ],
        ),
      ),
    );
  }
}


class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<Survey> surveys;

  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surveys.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final endTimeFormatted = 
            DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);

        return SurveyCard(
          endTimeFormatted: endTimeFormatted,
          name: survey.name,
          description: survey.description,
          onTap: () {
            context.pushNamed(
              Routes.submitSurveyName,
              extra: survey,
            );
          },
        );
      },
    );
  }
}

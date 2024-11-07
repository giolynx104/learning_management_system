import 'package:flutter/material.dart';
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/screens/create_survey_screen.dart';
import 'package:learning_management_system/screens/edit_survey_screen.dart';

class TeacherSurveyListScreen extends StatefulWidget {
  const TeacherSurveyListScreen({super.key});

  @override
  TeacherSurveyListScreenState createState() => TeacherSurveyListScreenState();
}

class TeacherSurveyListScreenState extends State<TeacherSurveyListScreen> {
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
    return surveys.where((survey) => survey.endTime.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<TeacherSurvey> getOverdueSurveys() {
    return surveys.where((survey) => survey.endTime.isBefore(DateTime.now())).toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SURVEY LIST',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Times New Roman',
                ),
              ),
              Image.asset(
                'assets/images/HUST_white.png',
                height: 30,
                fit: BoxFit.contain,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Quá hạn'),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(title: 'Sắp tới', surveys: getUpcomingSurveys()),
            SurveyTabContent(title: 'Quá hạn', surveys: getOverdueSurveys()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push(Routes.nestedCreateSurvey); // Use context.push for navigation
          },
          backgroundColor: Colors.red[900],
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<TeacherSurvey> surveys;

  const SurveyTabContent({super.key, required this.title, required this.surveys});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surveys.length,
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final startTimeFormatted = DateFormat('HH:mm dd-MM-yyyy').format(survey.startTime);
        final endTimeFormatted = DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 4.0),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$startTimeFormatted đến $endTimeFormatted',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8.0),
                    Text(survey.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8.0),
                    Text('Số phản hồi: ${survey.responseCount}'),
                    Text('Lớp: ${survey.className}'),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (value) {
                      if (value == 0) {
                        // Use context.push for navigation to EditSurveyScreen
                        context.push(
                          Routes.nestedEditSurvey, // Pass the survey ID or name to identify it
                          extra: TeacherSmallSurvey(
                            name: survey.name,
                            description: survey.description,
                            file: survey.file,
                            startTime: survey.startTime,
                            endTime: survey.endTime,
                          ),
                        );
                      } else if (value == 1) {
                        // Implement delete functionality later
                      } else if (value == 2) {
                        // Implement get response functionality later
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: const [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: const [
                            Icon(Icons.receipt_long, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Get Response'),
                          ],
                        ),
                      ),
                    ],
                  ),
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

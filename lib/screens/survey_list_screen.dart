import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key});

  @override
  SurveyListScreenState createState() => SurveyListScreenState();
}

class SurveyListScreenState extends State<SurveyListScreen> {
  final List<Survey> surveys = [
    Survey(
      name: 'Survey 1',
      description: 'This is a description for Survey 1',
      file: 'path/to/survey1.docx',
      answerDescription: null,
      answerFile: null,
      endTime: DateTime.now().add(const Duration(hours: 1)),
      turnInTime: null,
      className: 'Math 101',
    ),
    Survey(
      name: 'Survey 2',
      description: 'This is a description for Survey 2',
      file: 'path/to/survey2.docx',
      answerDescription: null,
      answerFile: null,
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      turnInTime: null,
      className: 'Science 101',
    ),
    Survey(
      name: 'Survey 3',
      description: null,
      file: null,
      answerDescription: 'Answer description for Survey 3',
      answerFile: 'path/to/answer3.docx',
      endTime: DateTime.now().add(const Duration(hours: 2)),
      turnInTime: DateTime.now().subtract(const Duration(minutes: 30)), // Turned in 30 minutes ago
      className: 'History 101',
    ),
    // Add more surveys as needed
  ];

  List<Survey> getUpcomingSurveys() {
    return surveys.where((survey) => survey.endTime.isAfter(DateTime.now()) && survey.turnInTime == null).toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<Survey> getOverdueSurveys() {
    return surveys.where((survey) => survey.endTime.isBefore(DateTime.now()) && survey.turnInTime == null).toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<Survey> getCompletedSurveys() {
    return surveys.where((survey) => survey.turnInTime != null).toList()
      ..sort((a, b) => a.turnInTime!.compareTo(b.turnInTime!));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              const SizedBox(height: 5.0),
              Image.asset(
                'assets/images/HUST_white.png',
                height: 30,
                fit: BoxFit.contain,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Quá hạn'),
              Tab(text: 'Đã hoàn thành'),
            ],
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(title: 'Sắp tới', surveys: getUpcomingSurveys()),
            SurveyTabContent(title: 'Quá hạn', surveys: getOverdueSurveys()),
            SurveyTabContent(title: 'Đã hoàn thành', surveys: getCompletedSurveys()),
          ],
        ),
      ),
    );
  }
}



class Survey {
  final String name;
  final String? description;
  final String? file; // Path or URL to the survey file
  final String? answerDescription;
  final String? answerFile; // Path or URL to the answer file
  final DateTime endTime;
  final DateTime? turnInTime; // New attribute for turn-in time
  final String className;

  const Survey({
    required this.name,
    this.description,
    this.file,
    this.answerDescription,
    this.answerFile,
    required this.endTime,
    required this.turnInTime, // Initialize turn-in time
    required this.className,
  });
}



class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<Survey> surveys;

  const SurveyTabContent({super.key, required this.title, required this.surveys});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: surveys.length,
        itemBuilder: (context, index) {
          final survey = surveys[index];
          final endTimeFormatted = DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);
          final turnInTimeFormatted = survey.turnInTime != null
              ? DateFormat('HH:mm dd-MM-yyyy').format(survey.turnInTime!)
              : null;

          return Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 4.0),
            child: InkWell(
              onTap: () {
                context.push(
                  Routes.submitSurvey,
                  extra: SmallSurvey(
                    name: survey.name,
                    description: survey.description,
                    file: survey.file,
                    answerDescription: survey.answerDescription,
                    answerFile: survey.answerFile,
                    endTime: survey.endTime,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      endTimeFormatted,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(survey.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    if (survey.description != null)
                      Text(survey.description!, style: const TextStyle(color: Colors.black)),
                    const SizedBox(height: 8.0),
                    if (survey.turnInTime != null)
                      Text(
                        'Đã nộp vào lúc $turnInTimeFormatted',
                      ),
                    Text('Lớp: ${survey.className}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


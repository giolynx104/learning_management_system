import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DetailedRollCallInfoScreen extends HookConsumerWidget {
  final String classId;

  const DetailedRollCallInfoScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final isSearchingById = useState(false);
    final filteredStudents = useState(mockStudents);

    void filterStudents(String query) {
      if (query.isEmpty) {
        filteredStudents.value = mockStudents;
      } else {
        filteredStudents.value = mockStudents.where((student) {
          if (isSearchingById.value) {
            return student.id.toLowerCase().contains(query.toLowerCase());
          } else {
            return student.name.toLowerCase().contains(query.toLowerCase());
          }
        }).toList();
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search by ${isSearchingById.value ? 'ID' : 'Name'}',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: filterStudents,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    isSearchingById.value = !isSearchingById.value;
                    searchController.clear();
                    filterStudents('');
                  },
                  child: Text(
                      'Search by ${isSearchingById.value ? 'Name' : 'ID'}'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Total Absences')),
                    DataColumn(label: Text('Student ID')),
                  ],
                  rows: filteredStudents.value
                      .map(
                        (student) => DataRow(
                          cells: [
                            DataCell(Text(student.name)),
                            DataCell(Text(student.totalAbsences.toString())),
                            DataCell(Text(student.id)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Student {
  final String name;
  final String id;
  final int totalAbsences;

  const Student({
    required this.name,
    required this.id,
    required this.totalAbsences,
  });
}

final List<Student> mockStudents = [
  const Student(name: 'John Doe', id: 'S001', totalAbsences: 3),
  const Student(name: 'Jane Smith', id: 'S002', totalAbsences: 1),
  const Student(name: 'Bob Johnson', id: 'S003', totalAbsences: 2),
  const Student(name: 'Alice Brown', id: 'S004', totalAbsences: 0),
  const Student(name: 'Charlie Davis', id: 'S005', totalAbsences: 4),
];

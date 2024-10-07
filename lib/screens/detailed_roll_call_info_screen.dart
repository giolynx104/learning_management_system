import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailedRollCallInfoScreen extends ConsumerStatefulWidget {
  const DetailedRollCallInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DetailedRollCallInfoScreen> createState() =>
      _DetailedRollCallInfoScreenState();
}

class _DetailedRollCallInfoScreenState
    extends ConsumerState<DetailedRollCallInfoScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchingById = false;
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _filteredStudents = mockStudents;
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = mockStudents;
      } else {
        _filteredStudents = mockStudents.where((student) {
          if (_isSearchingById) {
            return student.id.toLowerCase().contains(query.toLowerCase());
          } else {
            return student.name.toLowerCase().contains(query.toLowerCase());
          }
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Roll Call Info'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search by ${_isSearchingById ? 'ID' : 'Name'}',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: _filterStudents,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSearchingById = !_isSearchingById;
                      _searchController.clear();
                      _filterStudents('');
                    });
                  },
                  child: Text('Search by ${_isSearchingById ? 'Name' : 'ID'}'),
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
                  rows: _filteredStudents
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
  Student(name: 'John Doe', id: 'S001', totalAbsences: 3),
  Student(name: 'Jane Smith', id: 'S002', totalAbsences: 1),
  Student(name: 'Bob Johnson', id: 'S003', totalAbsences: 2),
  Student(name: 'Alice Brown', id: 'S004', totalAbsences: 0),
  Student(name: 'Charlie Davis', id: 'S005', totalAbsences: 4),
];

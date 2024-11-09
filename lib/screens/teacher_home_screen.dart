import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/mixins/sign_out_mixin.dart';
import 'package:learning_management_system/models/class_list_model.dart';
import 'package:learning_management_system/models/pinnedChannel.dart';
import 'package:learning_management_system/models/teams.dart';
import 'package:learning_management_system/routes/routes.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> with SignOutMixin {
  List<TeamsModel> teams = [];
  List<PinnedChannelModel> pinnedChannels = [];

  @override
  void initState() {
    super.initState();
    _getTeams();
    _getPinnedChannel();
  }

  void _getPinnedChannel() {
    setState(() {
      pinnedChannels = PinnedChannelModel.getPinnedChannels();
    });
  }

  void _getTeams() {
    setState(() {
      teams = TeamsModel.getTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleSignOut(),
          ),
        ],
      ),
      body: ListView(
        children: [
          _searchField(),
          const SizedBox(height: 20),
          // ... rest of home content
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(10),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.search),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _unpinChannel(PinnedChannelModel channel) {
    setState(() {
      PinnedChannelModel.removePinnedChannel(channel);
      pinnedChannels.removeWhere((pinned) => !pinned.isPinned);
    });
  }

  void _showTeamOptions(BuildContext context, TeamsModel team) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                team.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.class_rounded),
                title: const Text('Chỉnh sửa lớp'),
                onTap: () {
                  context.pop();
                  context.push(Routes.nestedModifyClass);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Giao bài tập'),
                onTap: () => context.push(Routes.nestedTeacherSurveyList),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Tài liệu'),
                onTap: () {
                  context.pop();
                  context.push(Routes.nestedUploadFile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Điểm danh'),
                onTap: () {
                  context.pop();
                  context.push(Routes.nestedRollCallAction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.poll),
                title: const Text('Tạo khảo sát'),
                onTap: () {
                  context.pop();
                  context.push(Routes.nestedCreateSurvey);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Rời khỏi nhóm'),
                onTap: () {
                  context.pop();
                  _showConfirmationDialog(context, team);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, TeamsModel team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn có chắc chắn muốn rời khỏi nhóm "${team.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}

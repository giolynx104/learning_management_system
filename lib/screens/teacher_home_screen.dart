import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/components/pinned_item.dart';
import 'package:learning_management_system/components/teams_item.dart';
import 'package:learning_management_system/mixins/sign_out_mixin.dart';
import 'package:learning_management_system/models/pinnedChannel.dart';
import 'package:learning_management_system/models/teams.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> with SignOutMixin {
  List<TeamsModel> teams = [];
  bool isClassesExpanded = false;
  bool isPinnedChannelExpanded = false;
  int _selectedIndex = 2;
  List<PinnedChannelModel> pinnedChannels = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
  void initState() {
    super.initState();
    _getTeams();
    _getPinnedChannel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Teacher Home', style: TextStyle(color: theme.colorScheme.onPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
            onPressed: () => handleSignOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ExpansionTile(
                  title: Text(
                    'Pinned Channels',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(
                    isPinnedChannelExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  ),
                  trailing: const SizedBox.shrink(),
                  onExpansionChanged: (bool expanded) {
                    setState(() => isPinnedChannelExpanded = expanded);
                  },
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pinnedChannels.length,
                      itemBuilder: (context, index) {
                        var channel = pinnedChannels[index];
                        return PinnedItem(
                          channel: channel,
                          onUnpinPressed: () => _unpinChannel(channel),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ExpansionTile(
                  title: Text(
                    'Classes',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(
                    isClassesExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.push(Routes.nestedCreateClass),
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() => isClassesExpanded = expanded);
                  },
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        var team = teams[index];
                        return TeamsExpansionItem(
                          name: team.name,
                          color: team.color,
                          onMorePressed: () => _showTeamOptions(context, team),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                onTap: () => context.pop(),
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

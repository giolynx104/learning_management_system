import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/components/pinned_item.dart';
import 'package:learning_management_system/components/teams_item.dart';
import 'package:learning_management_system/models/pinnedChannel.dart';
import 'package:learning_management_system/models/teams.dart';
import 'package:learning_management_system/mixins/sign_out_mixin.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> with SignOutMixin {
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

  void _getPinnedChanel() {
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
    _getPinnedChanel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      endDrawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchField(),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pinnedChannels(),
                const SizedBox(height: 20),
                _teams(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pinnedChannels() {
    return ExpansionTile(
      title: const Text("Pinned Channels"),
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
    );
  }

  Widget _teams() {
    return ExpansionTile(
      title: const Text("Classes"),
      leading: Icon(
        isClassesExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
      ),
      trailing: const SizedBox.shrink(),
      // tilePadding: EdgeInsets.zero,
      // childrenPadding:  EdgeInsets.zero,
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
    );
  }

  Container _searchField() {
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

  PreferredSizeWidget appBar() {
    return AppBar(
      title: const Text(
        'QLDT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.red,
      elevation: 0.0,
      actions: [
        Builder(
          // Wrap the Padding with Builder
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final userState = ref.watch(authProvider);

    return Drawer(
      child: userState.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                accountName: Text('${user.firstName} ${user.lastName}'),
                accountEmail: Text(user.email),
                currentAccountPicture: user.avatar != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar!),
                        backgroundColor: Colors.white,
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.red),
                      ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  context.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  context.pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.pop();
                  handleSignOut();
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user data: $error'),
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
        return Container(
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
                leading: const Icon(Icons.description),
                title: const Text('Tài liệu'),
                onTap: () {
                  context.pop(); // Use go_router
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_busy),
                title: const Text('Xin nghỉ'),
                onTap: () {
                  context.pop(); // Close bottom sheet first
                  context.push(Routes.nestedAbsentRequest);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Bài tập'),
                onTap: () {
                  context.pop(); // Use go_router
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Danh sách khảo sát'),
                onTap: () {
                  context.pop(); // Close bottom sheet first
                  context.push(Routes.nestedSurveyList);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Rời khỏi nhóm'),
                onTap: () {
                  context.pop(); // Close bottom sheet using go_router
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
              onPressed: () => context.pop(), // Use go_router
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => context.pop(), // Use go_router
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}

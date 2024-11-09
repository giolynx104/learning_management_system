import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/components/pinned_item.dart';
import 'package:learning_management_system/components/teams_item.dart';
import 'package:learning_management_system/mixins/sign_out_mixin.dart';
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
  bool isClassesExpanded = true;
  bool isPinnedChannelExpanded = false;
  List<PinnedChannelModel> pinnedChannels = [];

  void _getPinnedChanel(){
    setState(() {
      pinnedChannels = PinnedChannelModel.getPinnedChannels();
    });
  }

  void _getTeams() {
    setState(() {
      teams = TeamsModel.getTeams();
    });
  }

  void _unpinChannel(PinnedChannelModel channel) {
    setState(() {
      pinnedChannels.remove(channel);
    });
  }

  void _showTeamOptions(BuildContext context, TeamsModel team) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              context.pop();
              context.push(Routes.modifyClass, extra: team);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Implement delete functionality
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchField(),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
      initiallyExpanded: true,
      title: const Text("Classes"),
      leading: Icon(
        isClassesExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => context.push(
                  Routes.nestedCreateClass
                ) ,
        ),
      onExpansionChanged: (bool expanded) {
        setState(() => isClassesExpanded = expanded);
      },
      children: [
        ListView.builder(
          shrinkWrap: true,
          padding:  EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            var team = teams[index];
            return TeamsItem(
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
}

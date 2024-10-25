
import 'package:flutter/material.dart';
import 'package:learning_management_system/components/pinned_item.dart';
import 'package:learning_management_system/components/teams_item.dart';
import 'package:learning_management_system/models/pinnedChannel.dart';
import 'package:learning_management_system/models/teams.dart';
class StudentHomeScreen extends StatefulWidget {
   const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Noti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
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
          padding:  EdgeInsets.zero,
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

  AppBar appBar() {
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
                leading: const Icon(Icons.group),
                title: const Text('Tài liệu'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Xin nghỉ'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
                ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Bài tập'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Rời khỏi nhóm'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

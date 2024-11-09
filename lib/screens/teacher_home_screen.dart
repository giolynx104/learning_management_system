import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/mixins/sign_out_mixin.dart';
import 'package:learning_management_system/models/pinnedChannel.dart';
import 'package:learning_management_system/models/teams.dart';

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
}

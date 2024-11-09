import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/destinations.dart';

class LayoutScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Destination> destinations;
  const LayoutScaffold({
    required this.destinations,
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('LayoutScaffold'));

  @override
  State<LayoutScaffold> createState() => _LayoutScaffoldState();
}

class _LayoutScaffoldState extends State<LayoutScaffold> {
  String appBarTitle = "Microsoft Teams";

  @override
  void initState() {
    super.initState();
    appBarTitle = widget.destinations[widget.navigationShell.currentIndex].label;
  }

  void updateAppBarTitle(int index) {
    setState(() {
      appBarTitle = widget.destinations[index].label;
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.ibb.co/y562zHM/poroys.jpg'),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, appBarTitle),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "Do Minh Tuan 20210901",
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              accountEmail: Text(
                "tuan.dm210901@sis.hust.edu.vn",
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: const NetworkImage('https://i.ibb.co/y562zHM/poroys.jpg'),
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Trực tuyến"),
              onTap: () {
                // Handle online status click
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Cài đặt trạng thái thông báo"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Cài đặt"),
              onTap: () => _showOptions(context),
            ),
            const Divider(),
            const ListTile(
              title: Text("Tài khoản và tổ chức"),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Hanoi University of Science and Technology"),
              subtitle: const Text("tuan.dm210901@sis.hust.edu.vn"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Thêm tài khoản"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(index);
          updateAppBarTitle(index);
        },
        indicatorColor: Colors.red,
        destinations: widget.destinations
            .map((destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  label: destination.label,
                  selectedIcon: Icon(destination.onPressedIcon, color: Colors.white),
                ))
            .toList(),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.key_off),
                title: const Text('Đổi mật khẩu'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Đăng xuất'),
                onTap: () {
                  Navigator.pop(context);
                  _showConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}

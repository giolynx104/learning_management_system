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
    // Initialize appBarTitle based on the initial index if needed
    appBarTitle = widget.destinations[widget.navigationShell.currentIndex].label;
  }

  void updateAppBarTitle(int index) {
    setState(() {
      appBarTitle = widget.destinations[index].label;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
  
  appBar: AppBar(
  backgroundColor: Colors.red,
  elevation: 0,
  leading:Padding(
    padding: const EdgeInsets.all(8.0),
    child: Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage('https://i.ibb.co/y562zHM/poroys.jpg'), // Replace with your avatar URL
        ),
      ),
    ),
  ),
  title: Text(
        appBarTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
),

        drawer:  Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text("Do Minh Tuan 20210901"),
                  accountEmail: Text("tuan.dm210901@sis.hust.edu.vn"),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage('https://i.ibb.co/y562zHM/poroys.jpg'), // Replace with your avatar URL
                  ),
                  decoration: BoxDecoration(color: Colors.blue),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Trực tuyến"),
                  onTap: () {
                    // Handle online status click
                  },
                ),
              
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Cài đặt trạng thái thông báo"),
                  onTap: () {
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Cài đặt"),
                  onTap: () => _showOptions(context),
                ),
                Divider(),
                ListTile(
                  title: Text("Tài khoản và tổ chức"),
                ),
                
                ListTile(
                  leading: Icon(Icons.business),
                  title: Text("Hanoi University of Science and Technology"),
                  subtitle: Text("tuan.dm210901@sis.hust.edu.vn"),
                  onTap: () {
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text("Thêm tài khoản"),
                  onTap: () {
                    // Handle add account click
                  },
                ),
              ],
            ),
          ),
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
         // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
                onTap: () =>{}
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
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
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

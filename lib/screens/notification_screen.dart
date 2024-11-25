import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/models/notification_model.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/models/notifications.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:learning_management_system/services/notification_service.dart';


class NotificationScreen extends ConsumerStatefulWidget {
    const NotificationScreen({super.key});
  @override
  ConsumerState<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends ConsumerState<NotificationScreen> {
  final TextEditingController _notifyCodeController = TextEditingController();
  final FocusNode _notifyCodeFocusNode = FocusNode();
  Timer? _refreshTimer;
  bool _isDisposed = false;
  List<NotificationModel> _notificationList =[];
  bool connections =true;
  bool _isLoading = true;
  List<NotificationModels> notifications =[];
  void _getNotifications(){
    setState(() {
    notifications = NotificationModels.getNotifications();
    connections= true;
    });
  }
Future<void> _initializeNotificationData() async {
  debugPrint('NotificationManagementScreen - _initializeNotificationData started');
  if (!mounted) return;

  try {
    final authState = ref.read(authProvider);
    debugPrint('NotificationManagementScreen - authState: $authState');

    return authState.when(
      data: (user) async {
        debugPrint('NotificationManagementScreen - auth data received: ${user?.role}');
        if (user == null) {
          if (mounted) context.go(Routes.signin);
          return;
        }

        // Set up the refresh timer only after confirming authentication
        // _refreshTimer?.cancel(); // Cancel any existing timer
        // _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        //   debugPrint('NotificationManagementScreen - refresh timer triggered');
        //   if (mounted) {
        //     _refreshNotificationList();
        //   }
        // });

        // Load the initial notifications
        await _loadNotificationList();
      },
      loading: () {
        debugPrint('NotificationManagementScreen - auth loading');
        return null;
      },
      error: (e, __) {
        debugPrint('NotificationManagementScreen - auth error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error initializing notifications: $e')),
          );
          context.go(Routes.signin);
        }
      },
    );
  } catch (e, stackTrace) {
    debugPrint('NotificationManagementScreen - initialization error: $e');
    debugPrint('NotificationManagementScreen - stack trace: $stackTrace');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing notifications: $e')),
      );
      context.go(Routes.signin);
    }
  }
}

 @override
  void dispose() {
    debugPrint('ClassManagementScreen - dispose called');
    _isDisposed = true;
    _notifyCodeController.dispose();
    _notifyCodeFocusNode.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
 Future<void> _loadNotificationList() async {
  try {
    final authState = ref.read(authProvider);
    final token = authState.token;

    if (token == null) {
      if (mounted) {
        context.go(Routes.signin);
      }
      return;
    }
     setState(() {
        _isLoading = true; 
      });
    final notifications = await ref.read(notificationServiceProvider.notifier).getNotifications(token);

    if (mounted) {
        setState(() {
          _notificationList = notifications; 
          _isLoading = false; 
        });
      }
  } on UnauthorizedException {
    if (mounted) {
      ref.read(authProvider.notifier).signOut();
      context.go(Routes.signin);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

 void _refreshNotificationList() {
  _loadNotificationList();
}


  @override
  void initState(){
    super.initState();
   _initializeNotificationData();
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        //appBar: _appBar(),
        body: _isLoading
          ? Center(child: CircularProgressIndicator()) 
          : _notifiBody(),
      );
    
  }

  Widget _notifiBody() {   
    if(!connections){
        return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Không thể kết nối',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Todo : Nhấn để thử lại
              },
              child: const Text(
                'Nhấn để thử lại',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    else if(_notificationList.isEmpty){
      return const Center(
         child: Text(
              'Không có thông báo',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
          )
      );
    }
    else {
      return ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount:_notificationList.length ,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 30,),
        itemBuilder: (BuildContext context, int index) { 
           final notification = _notificationList[index]; 
           return NotifyItem(notification: notification);
        },
      );
    }
  }

  AppBar _appBar() {
    return AppBar(
    title: const Text(
      'Thông báo',
      style: TextStyle(
        color:Colors.white,
        fontSize: 25,
        
        ),
       ),
      centerTitle: true,
      backgroundColor: Colors.red,
        elevation: 0.0,
      );
  }
}




class NotifyItem extends StatelessWidget {
  const NotifyItem({
    Key? key,
    required this.notification,
  }) : super(key: key);

  final NotificationModel notification;

  String formatFriendlyTime(String sentTime) {
    try {
      final sentDateTime =
          DateFormat('yyyy-MM-ddTHH:mm:ss').parse(sentTime, true).toLocal();
      final now = DateTime.now();
      final difference = now.difference(sentDateTime);

      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('dd/MM/yyyy').format(sentDateTime);
      }
    } catch (e) {
      return sentTime;
    }
  }

  String formatDetailedTime(String sentTime) {
    try {
      final sentDateTime =
          DateFormat('yyyy-MM-ddTHH:mm:ss').parse(sentTime, true).toLocal();
      return 'at ${DateFormat('HH:mm:ss').format(sentDateTime)} on ${DateFormat('dd/MM/yyyy').format(sentDateTime)}';
    } catch (e) {
      return sentTime;
    }
  }
  // Helper function to convert Google Drive URL to direct link
String getDirectImageUrl(String url) {
  final uri = Uri.parse(url);
  if (uri.host == 'drive.google.com') {
    final segments = uri.pathSegments;
    if (segments.length >= 3 && segments[0] == 'file' && segments[1] == 'd') {
      final fileId = segments[2];
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
  }
  return url;
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showNotificationDetailed(context);
      },
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 30,
              right: 30,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    notification.status == 'UNREAD' ? Colors.red : Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.11),
                  blurRadius: 40,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'QLDT',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      formatFriendlyTime(notification.sentTime),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'From: ${notification.fromUser}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                  thickness: 1,
                ),
                const SizedBox(height: 10),
                // Notification Title
                Text(
                  notification.titlePushNotification,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                // "Chi tiết" Link
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
 
          if (notification.status == 'UNREAD')
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<dynamic> _showNotificationDetailed(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(
            child: Text(
              notification.titlePushNotification,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text('From: ${notification.fromUser}'),
                Text(formatDetailedTime(notification.sentTime)),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Content:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(notification.message),
                const SizedBox(height: 8),
                // Display image if available
                if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                       GestureDetector(
                        onTap: () {
                          // Show full image when tapped
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: Stack(
                                children: [
                                  // Full-screen image
                                  InteractiveViewer(
                                    child: Image.network(
                                      getDirectImageUrl(notification.imageUrl!),
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Text('Failed to load image.'),
                                        );
                                      },
                                    ),
                                  ),
                                  // Close button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Image.network(
                            getDirectImageUrl(notification.imageUrl!),
                            height: 200, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Failed to load image.');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

              ],
            ),
          ),
          actions: [
        
            if (notification.type == 'ABSENCE') ...[
              TextButton(
                onPressed: () {

                  Navigator.of(context).pop();
             
                },
                child: const Text('Accept'),
              ),
              TextButton(
                onPressed: () {
               
                  Navigator.of(context).pop();
              
                },
                child: const Text('Decline'),
              ),
            ] else
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
          ],
        ),
      );
  }
}

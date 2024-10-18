import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:learning_management_system/models/notifications.dart';
class NotificationPage extends StatefulWidget {
    const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications =[];
  bool connections =false;

  void _getNotifications(){
    setState(() {
    notifications = NotificationModel.getNotifications();
    connections= true;
    });
    
  }

 

  @override
  void initState(){
    super.initState();
   _getNotifications();
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: _appBar(),
        body: _notifiBody(),
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
    else if(notifications.isEmpty){
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
        itemCount:notifications.length ,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 30,),
        itemBuilder: (BuildContext context, int index) {  
           return Container(
            padding: const EdgeInsets.only(
                  top: 10,
                  left: 30,
                  right: 30,
                  bottom: 20,
                 ),
              decoration: BoxDecoration(
                border: Border.all(width: 1) ,
                borderRadius: BorderRadius.circular(20),
                boxShadow:[ 
                  BoxShadow(
                    color: Colors.black.withOpacity(0.11),
                    blurRadius: 40,
                    spreadRadius: 0.0,
                  ),]
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
                        ) 
                      ),
                   
                    Text(
                      notifications[index].createDate,
                      style: const TextStyle(
                          color: Colors.grey,
                      ),
                    )
                  ], 
                ),
                 const SizedBox(
                  height: 10,
                ),
               Text(
                    notifications[index].fromClass,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
               
                const SizedBox(
                  height: 15,
                ),
                const Divider(
                    height: 1, 
                    color: Colors.grey,
                    thickness: 1, 
                    
                ),
                const SizedBox(
                  height: 10,
                ),
             
                Text(
                    notifications[index].title,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                  ),
                  
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[ 
                    Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ]
               ),
               
               ],
             ),
           );
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
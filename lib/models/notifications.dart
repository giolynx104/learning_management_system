import 'package:intl/intl.dart';
class NotificationModel{
    String title;
    String? content;
    String fromClass;
    String createDate;
    NotificationModel({
      required this.title,
      required this.fromClass,
      required this.content,
      required this.createDate,
    });
   
    static List<NotificationModel> getNotifications(){
      List<NotificationModel> notifications =[];
      notifications.add(NotificationModel(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
         );
      notifications.add(NotificationModel(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );
      notifications.add(NotificationModel(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );
        notifications.add(NotificationModel(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );
        notifications.add(NotificationModel(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );

      return notifications;   
    }

}
import 'package:intl/intl.dart';
class NotificationModels{
    String title;
    String? content;
    String fromClass;
    String createDate;
    NotificationModels({
      required this.title,
      required this.fromClass,
      required this.content,
      required this.createDate,
    });
   
    static List<NotificationModels> getNotifications(){
      List<NotificationModels> notifications =[];
      notifications.add(NotificationModels(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
         );
      notifications.add(NotificationModels(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );
      notifications.add(NotificationModels(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );
        notifications.add(NotificationModels(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );
        notifications.add(NotificationModels(
        title: 'Grade for 2nd test',
         fromClass: 'TKXDPM', 
         content: 'Hello, this is the noti', 
         createDate: DateFormat('dd/MM/yyyy').format(DateTime.now()),
         )
      );

      return notifications;   
    }

}
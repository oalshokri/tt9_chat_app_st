import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tt9_chat_app_st/models/my_notification.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NotificationsScreen extends StatefulWidget {
  final List<MyNotification> notifications;
  const NotificationsScreen({super.key, required this.notifications});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // scrollController.addListener(() { });
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView.separated(
        controller: scrollController,
        itemBuilder: (context, index) {
          final notification = widget.notifications[index];
          print(index);
          return VisibilityDetector(
            key: ValueKey('${notification.message.messageId}'),
            onVisibilityChanged: (VisibilityInfo info) {
              var visiblePercentage = info.visibleFraction * 100;
              if (visiblePercentage == 100) {
                setState(() {
                  notification.isRead = true;
                });
              }
              debugPrint('Widget ${info.key} is ${visiblePercentage}% visible');
            },
            child: ListTile(
              title: Text('${notification.message.notification!.title}'),
              subtitle: Text('${notification.message.notification!.body}'),
              trailing: CircleAvatar(
                radius: 5,
                backgroundColor: notification.isRead
                    ? Colors.grey[400]
                    : Colors.lightBlueAccent,
              ),
            ),
          );
          // return VisibilityDetector(
          //   key: ValueKey('${notification.message.messageId}'),
          //   onVisibilityChanged: (VisibilityInfo visibilityInfo) {
          //     var visiblePercentage = visibilityInfo.visibleFraction * 100;
          //     if (visiblePercentage == 100) {
          //       setState(() {
          //         notification.isRead = true;
          //       });
          //     }
          //
          //     debugPrint(
          //         'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
          //   },
          //   child: ListTile(
          //     title: Text('${notification.message.notification!.title}'),
          //     subtitle: Text('${notification.message.notification!.body}'),
          //     trailing: CircleAvatar(
          //       radius: 5,
          //       backgroundColor: notification.isRead
          //           ? Colors.grey[400]
          //           : Colors.lightBlueAccent,
          //     ),
          //   ),
          // );
        },
        separatorBuilder: (context, index) {
          return Column(
            children: [
              Divider(
                endIndent: 12,
                indent: 12,
              ),
              SizedBox(
                height: 100,
              ),
            ],
          );
        },
        itemCount: widget.notifications.length,
      ),
    );
  }
}

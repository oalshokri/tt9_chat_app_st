import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  final List<RemoteMessage> notifications;
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
      body: ListView.separated(
        controller: scrollController,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${widget.notifications[index].notification!.title}'),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 100,
          );
        },
        itemCount: widget.notifications.length,
      ),
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tt9_chat_app_st/screens/login_screen.dart';

import '../constants.dart';
import 'notification_screen.dart';

class ChatScreen extends StatefulWidget {
  static const id = '/chatScreen';
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController messageCnt = TextEditingController();

  User? user;
  bool isTyping = false;
  Timer? _timer;

  List<RemoteMessage> notifications = [];

  void getUser() {
    user = _auth.currentUser;

    if (user != null) {
      print('Current User : ${user!.email}');
    }
  }

  // void getMessages() {
  //   db.collection('messages').get().then((value) {
  //     final docs = value.docs;
  //     for (var message in docs) {
  //       print(message.data());
  //     }
  //   });
  // }

  void streamMessages() async {
    await for (var messages in db.collection('messages').snapshots()) {
      for (var message in messages.docs) {
        print(message.data());
      }
    }
  }

  void removeTyper() async {
    await db.collection('typing').doc(user?.email).delete();
  }

  void getNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        setState(() {
          notifications.add(message);
        });

        // print(
        //     'Message also contained a notification: ${message.notification!.title}');
      }
    });
  }

  @override
  void initState() {
    getUser();
    // getMessages();
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        removeTyper();
        print('clicked from iphone');
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return NotificationsScreen(
                      notifications: notifications,
                    );
                  })).then((value) => setState(() {
                        // notifications.clear();
                      }));
                },
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    notifications.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '${notifications.length}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          )
                        : SizedBox(),
                  ],
                )),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  //Implement logout functionality
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.id, (route) => false);
                  removeTyper();
                  _auth.signOut();
                }),
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚡️Chat'),
              StreamBuilder(
                  stream: db.collection('typing').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final typers = snapshot.data?.docs;
                      String names = '';
                      for (var item in typers!) {
                        if (user!.email != item.get('email')) {
                          if (names.isNotEmpty) {
                            names = '$names, ${item.get('email')}';
                          } else {
                            names = item.get('email');
                          }
                        }
                      }
                      if (names.isNotEmpty) {
                        names = '$names Typing';
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: SizedBox(
                          height: 12,
                          child: SingleChildScrollView(
                            child: Text(
                              '$names',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          // child: ListView.separated(
                          //   scrollDirection: Axis.horizontal,
                          //   itemBuilder: (context, index) {
                          //     if (typers[index].get('email') == user!.email) {
                          //       return const SizedBox();
                          //     }
                          //     if (index == typers.length - 1) {
                          //       return Text(
                          //         '${typers[index].get('email')} typing',
                          //         style: const TextStyle(fontSize: 10),
                          //       );
                          //     }
                          //     return Text(
                          //       '${typers[index].get('email')}',
                          //       style: const TextStyle(fontSize: 10),
                          //     );
                          //   },
                          //   separatorBuilder:
                          //       (BuildContext context, int index) {
                          //     return const Text(
                          //       ', ',
                          //       style: TextStyle(fontSize: 10),
                          //     );
                          //   },
                          //   itemCount: typers!.length,
                          // ),
                        ),
                      );
                    } else {
                      return const Text(
                        '',
                        style: TextStyle(fontSize: 10),
                      );
                    }
                  }),
            ],
          ),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                  stream: db
                      .collection('messages')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final messages = snapshot.data!.docs;
                      return Expanded(
                        child: ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.all(12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return BubbleMessage(
                                message: messages[index].data()['text'],
                                sender: messages[index].data()['sender'],
                                isMe: messages[index].data()['sender'] ==
                                    user!.email,
                              );
                            }),
                      );
                    }
                    return Text('loading');
                  }),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageCnt,
                        onChanged: (value) {
                          print('111111');
                          if (_timer?.isActive ?? false) _timer!.cancel();
                          _timer = Timer(const Duration(milliseconds: 500), () {
                            print('22222 inside');
                            if (user?.email != null && value.isNotEmpty) {
                              db
                                  .collection('typing')
                                  .doc(user?.email ?? '')
                                  .set({'email': user?.email});
                            }
                            if (value.isEmpty) {
                              removeTyper();
                            }
                          });
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //Implement send functionality.
                        db.collection('messages').add({
                          'text': messageCnt.text,
                          'sender': user!.email,
                          'time': DateTime.now()
                        }).then((value) {
                          messageCnt.clear();
                          removeTyper();
                        }).catchError((err) {
                          print(err);
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BubbleMessage extends StatelessWidget {
  const BubbleMessage({
    super.key,
    required this.message,
    required this.sender,
    required this.isMe,
  });

  final String message;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.black54),
          ),
          Material(
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            borderRadius: isMe
                ? BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24))
                : BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                message,
                style: TextStyle(
                    fontSize: 18, color: isMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

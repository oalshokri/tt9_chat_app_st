import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tt9_chat_app_st/screens/login_screen.dart';

import '../constants.dart';

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

  @override
  void initState() {
    getUser();
    // getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.id, (route) => false);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
                stream: db.collection('typing').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return Text(
                        '${snapshot.data?.docs.first.get('email')}typing');
                  } else {
                    return SizedBox();
                  }
                }),
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
                        if (user?.email != null) {
                          db
                              .collection('typing')
                              .doc(user?.email ?? '')
                              .set({'email': user?.email});
                        }

                        if (value == '') {
                          removeTyper();
                        }
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

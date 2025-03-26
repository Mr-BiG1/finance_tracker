import 'package:flutter/material.dart';
import 'package:crisp_chat/crisp_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crisp_chat/crisp_chat.dart' as crisp;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String websiteID =
      "603a1fb9-9974-4b58-89b4-63ee1d0ab9ed"; // Crisp Website ID
  late CrispConfig config;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    final email = currentUser?.email ?? 'guest@example.com';
    final displayName = currentUser?.displayName ?? 'Guest User';

    config = CrispConfig(
      websiteID: websiteID,
      user: crisp.User(email: email, nickName: displayName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Support')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FlutterCrispChat.openCrispChat(config: config);
          },
          child: Text('Open Chat'),
        ),
      ),
    );
  }
}

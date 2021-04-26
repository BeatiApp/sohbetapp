import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/screens/chats/conversation_page.dart';

class ClosedChatsWidget extends StatelessWidget {
  final Conversation conversation;

  const ClosedChatsWidget({Key key, this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPage(
                conversation: conversation,
                userId: firebaseAuth.currentUser.uid,
              ),
            ));
      },
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(conversation.profileImage),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green[400], shape: BoxShape.circle),
                  child: Center(
                    child: Text("0"),
                  ),
                  width: 20,
                  height: 20,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

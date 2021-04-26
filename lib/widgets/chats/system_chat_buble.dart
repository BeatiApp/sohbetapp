import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemChatBubble extends StatelessWidget {
  final Map<String, dynamic> chatData;

  const SystemChatBubble({Key key, this.chatData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            chatData['message'],
            maxLines: 1,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColor.withOpacity(0.75),
        ),
        alignment: Alignment.center,
      ),
    );
  }
}

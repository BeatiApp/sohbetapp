import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnsweredMessageWidget extends StatelessWidget {
  final Map answeredMessageData;
  final Function closeFunction;

  const AnsweredMessageWidget(
      {Key key, this.answeredMessageData, this.closeFunction})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.only(left: 10),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Text(
                answeredMessageData['senderName'],
                style: GoogleFonts.roboto(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                answeredMessageData['message'],
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 10,
        ),
        IconButton(icon: Icon(Icons.close), onPressed: closeFunction),
      ],
    );
  }
}

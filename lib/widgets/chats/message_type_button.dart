import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageTypeButton extends StatelessWidget {
  final Function onPressed;
  final String assetImagePath;
  final String buttonName;

  const MessageTypeButton(
      {Key key,
      @required this.onPressed,
      @required this.assetImagePath,
      @required this.buttonName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Column(
        children: [
          SvgPicture.asset(
            assetImagePath,
            height: 50,
            width: 50,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            buttonName,
            style: GoogleFonts.roboto(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

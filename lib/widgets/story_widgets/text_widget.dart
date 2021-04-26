import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatelessWidget {
  final String text;

  const TextWidget({Key key, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: 30,
            minHeight: 20,
            maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              text ?? "TEXT",
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 30),
            ),
          ),
          color: Colors.white54.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}

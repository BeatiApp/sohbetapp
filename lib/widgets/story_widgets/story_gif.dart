import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryGif extends StatelessWidget {
  final String gifImage;

  const StoryGif({Key key, this.gifImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return gifImage == null
        ? Container(
            alignment: Alignment.center,
            height: 100,
            width: 100,
            child: Text(
              "GIF",
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.white38.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25)),
          )
        : Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(gifImage))),
          );
  }
}

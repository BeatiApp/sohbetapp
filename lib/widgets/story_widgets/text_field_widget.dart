import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryTextWidget extends StatelessWidget {
  final TextEditingController controller;

  const StoryTextWidget({Key key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: TextField(
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            controller: controller,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 30),
          ),
        ),
      ),
    );
  }
}

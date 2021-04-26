import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat("HH:mm");
    return Container(
      height: 60,
      width: 150,
      child: Card(
        child: Center(
            child: Text(
          dateFormat.format(DateTime.now()),
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 30),
        )),
        color: Colors.white54.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}

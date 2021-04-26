import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardTextField extends StatelessWidget {
  const CardTextField({
    this.controller,
    @required this.labelText,
    this.keyboardType,
    @required this.iconData,
    this.obscureText,
    this.initialValue,
  });

  final TextEditingController controller;
  final String labelText;
  final String initialValue;
  final TextInputType keyboardType;
  final IconData iconData;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          initialValue: initialValue,
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          style: GoogleFonts.roboto(
            fontSize: 20.0,
            color: Colors.black,
          ),
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(iconData, color: Color(0xff457B9D)),
            labelText: labelText,
            labelStyle: GoogleFonts.roboto(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)
                .copyWith(color: Color(0xff457B9D)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

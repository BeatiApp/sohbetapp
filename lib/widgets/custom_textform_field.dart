import 'package:flutter/material.dart';
import 'package:sohbetapp/widgets/responsive_widget.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;
  final Widget obscureIcon;
  final TextInputType textInputType;
  final String Function(String) validate;
  CustomTextField({
    this.hint,
    this.textEditingController,
    this.keyboardType,
    this.icon,
    this.obscureText = false,
    this.obscureIcon,
    this.validate,
    this.textInputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    double _width;
    double _pixelRatio;
    bool large;
    bool medium;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: large ? 12 : (medium ? 10 : 8),
      child: TextFormField(
        validator: validate,
        controller: textEditingController,
        keyboardType: keyboardType,
        cursorColor: Theme.of(context).accentColor,
        obscureText: obscureText,
        decoration: InputDecoration(
          suffixIcon: obscureIcon,
          prefixIcon:
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

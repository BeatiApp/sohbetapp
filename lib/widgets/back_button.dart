import 'package:flutter/material.dart';

Widget backButtonWidget(BuildContext context, Function func) {
  return IconButton(
    icon: Icon(Icons.arrow_back_ios),
    onPressed: () {
      Navigator.of(context).pop(func);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

AlertDialog privacyPolicy(BuildContext context) {
  return AlertDialog(
    actions: [
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("ANLADIM"))
    ],
    title: Text("Gizlilik Politikası"),
    content: Container(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 120,
          height: MediaQuery.of(context).size.height * 10,
          child: WebView(
            initialUrl: "https://zekkontro.github.io/sohbet-policy/",
          ),
        ),
      ),
    ),
  );
}

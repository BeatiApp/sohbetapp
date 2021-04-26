import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SizedPageRoute extends PageRouteBuilder {
  final Widget page;

  SizedPageRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
}

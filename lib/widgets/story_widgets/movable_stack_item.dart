import 'package:flutter/material.dart';

class MoveableStackItem extends StatefulWidget {
  final Widget widget;

  const MoveableStackItem({Key key, this.widget}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MoveableStackItemState();
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  double xPosition = 0;
  double yPosition = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
          onPanUpdate: (tapInfo) {
            setState(() {
              xPosition += tapInfo.delta.dx;
              yPosition += tapInfo.delta.dy;
            });
          },
          child: widget.widget),
    );
  }
}

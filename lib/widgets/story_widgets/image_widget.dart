import 'dart:io';

import 'package:flutter/material.dart';

class StoryImageWidget extends StatelessWidget {
  final String image;

  const StoryImageWidget({Key key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image == null
        ? SizedBox(
            height: 100,
            width: 100,
            child: Card(
                child: Center(
                    child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                )),
                color: Colors.white54.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))),
          )
        : Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                    fit: BoxFit.cover, image: FileImage(File(image)))),
            height: 300,
            width: 200,
          );
  }
}

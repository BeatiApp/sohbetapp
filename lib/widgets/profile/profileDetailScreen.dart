import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String imageURL;
  final String tag;
  const ProfileDetailScreen({Key key, this.imageURL, this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Hero(
          tag: tag,
          child: Center(
            child: Image.network(
              imageURL,
            ),
          ),
        ),
      ),
    );
  }
}

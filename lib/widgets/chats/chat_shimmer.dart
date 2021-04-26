import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmer extends StatefulWidget {
  @override
  _ChatShimmerState createState() => _ChatShimmerState();
}

class _ChatShimmerState extends State<ChatShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.grey[100],
      enabled: true,
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index % 2 == 0) {
            return Align(
                alignment: Alignment.centerRight,
                child: Container(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 100,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                                height: 10,
                                width: 10,
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle)),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 120,
                          height: 15,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 120,
                          height: 15,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 120,
                          height: 15,
                        ),
                      ],
                    )));
          } else {
            return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 100,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                                height: 10,
                                width: 10,
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle)),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 120,
                          height: 15,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 120,
                          height: 15,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 120,
                          height: 15,
                        ),
                      ],
                    )));
          }
        },
        itemCount: 15,
      ),
    );
  }
}

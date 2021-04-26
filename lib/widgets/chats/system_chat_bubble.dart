import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contextualactionbar/contextualactionbar.dart';
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sohbetapp/screens/review_pages/video_player.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:linkwell/linkwell.dart';
import 'package:sohbetapp/screens/review_pages/review_image.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/utilities/sensitive_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sohbetapp/utilities/right_page_route.dart';

class SystemNotificationBubble extends StatefulWidget {
  SystemNotificationBubble({
    @required this.chatData,
    this.list,
    this.convID,
    this.messageId,
  });

  final QueryDocumentSnapshot chatData;
  final List<String> list;
  final String convID;
  final String messageId;

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<SystemNotificationBubble> {
  final borderRadius = 20.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isMe =
        (firebaseAuth.currentUser.uid == widget.chatData.data()["senderId"]);
    DateFormat hoursAndMintues = DateFormat("HH:mm a");
    DateTime timestamp = widget.chatData.data()['date'].toDate();
    AudioPlayer audioPlayer = AudioPlayer(playerId: widget.messageId);
    bool playMode = false;
    final decoration = BoxDecoration(
      color: widget.chatData['type'] == "lostMessage"
          ? Colors.black54
          : (isMe
              ? Theme.of(context).iconTheme.color
              : Theme.of(context).primaryColor),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(isMe ? 0.0 : borderRadius),
        bottomRight: Radius.circular(isMe ? 0.0 : borderRadius),
        topLeft: Radius.circular(isMe ? borderRadius : 0.0),
        bottomLeft: Radius.circular(isMe ? borderRadius : 0.0),
      ),
    );

    Widget messageWidget() {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  widget.chatData.data()['senderName'],
                  style: GoogleFonts.roboto(
                    fontSize: 15.0,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: isMe
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                    hoursAndMintues.format(timestamp).toString().split(', ')[0],
                    style: GoogleFonts.roboto(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).iconTheme.color,
                    )),
                SizedBox(
                  width: 7,
                ),
                Icon(
                  widget.chatData.data()['seenData'] == true
                      ? Icons.verified
                      : Icons.verified_outlined,
                  size: 18,
                  color: isMe
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color,
                )
              ],
            ),
            SizedBox(height: 8),
            widget.chatData.data()['type'] == "image"
                ? Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(isMe ? 0.0 : borderRadius),
                        bottomRight: Radius.circular(isMe ? 0.0 : borderRadius),
                        topLeft: Radius.circular(isMe ? borderRadius : 0.0),
                        bottomLeft: Radius.circular(isMe ? borderRadius : 0.0),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ReviewImage(
                                        imageName:
                                            widget.chatData.data()['fileName'],
                                        imageURL:
                                            widget.chatData.data()["imageURL"],
                                      )));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInImage(
                              image: NetworkImage(
                                  widget.chatData.data()["imageURL"]),
                              fit: BoxFit.cover,
                              placeholder:
                                  AssetImage('assets/gifs/loading.gif'),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            LinkWell(widget.chatData.data()["message"],
                                linkStyle: GoogleFonts.roboto(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18.0,
                                    decoration: TextDecoration.underline),
                                style: GoogleFonts.roboto(
                                  fontSize: 18.0,
                                  color: Theme.of(context).splashColor,
                                ))
                          ],
                        ),
                      ),
                    ),
                  )
                : (widget.chatData['type'] == "file"
                    ? Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).iconTheme.color,
                            borderRadius: BorderRadius.circular(30)),
                        child: CupertinoButton(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage('assets/logos/file-logo.png'),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 120,
                                      child: Text(
                                        widget.chatData.data()['fileName'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(filesize(int.parse(widget.chatData
                                        .data()['id']['fileSize']))),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                File(storagePath +
                                            "/Files/" +
                                            widget.chatData.data()['fileName'])
                                        .existsSync()
                                    ? Container()
                                    : IconButton(
                                        icon: Icon(Icons.cloud_download),
                                        onPressed: () async {
                                          String savedPath = storagePath +
                                              "/Files/" +
                                              widget.chatData
                                                  .data()['fileName'];
                                          Dio dio = Dio();
                                          await dio.download(
                                              widget.chatData.data()['fileURL'],
                                              savedPath);
                                        },
                                      ),
                              ],
                            ),
                            onPressed: () {
                              if (File(storagePath +
                                      "/Files/" +
                                      widget.chatData.data()['fileName'])
                                  .existsSync()) {
                                OpenFile.open(storagePath +
                                    "/Files/" +
                                    widget.chatData.data()['fileName']);
                              }
                            }),
                      )
                    : (widget.chatData.data()['type'] == "location"
                        ? Container(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                            page: ReviewImage(
                                          imageName: "Alınan Konum Bilgisi",
                                          imageURL: widget.chatData
                                              .data()['locationSnapshot'],
                                        )));
                                  },
                                  child: SizedBox(
                                      height: 300,
                                      width: 300,
                                      child: Image.network(widget.chatData
                                          .data()['locationSnapshot'])),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      await launch(
                                          "https://www.google.com.tr/maps/@${widget.chatData.data()['latitude']},${widget.chatData.data()['longitude']},18z");
                                    },
                                    child: Text(
                                      widget.chatData.data()['locationName'],
                                      style: GoogleFonts.roboto(
                                          color: isMe
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                          decoration: TextDecoration.underline,
                                          fontSize: 20),
                                    ))
                              ],
                            ),
                          )
                        : widget.chatData.data()['type'] == "audio"
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).iconTheme.color,
                                    borderRadius: BorderRadius.circular(30)),
                                child: CupertinoButton(
                                    child: Row(
                                      children: [
                                        playMode == false
                                            ? IconButton(
                                                icon: Icon(Icons.play_arrow),
                                                onPressed: () async {
                                                  await audioPlayer.play(
                                                    widget.chatData
                                                        .data()['audioURL'],
                                                  );
                                                  setState(() {
                                                    playMode = true;
                                                  });
                                                })
                                            : IconButton(
                                                icon: Icon(Icons.pause),
                                                onPressed: () async {
                                                  await audioPlayer.pause();
                                                  setState(() {
                                                    playMode = false;
                                                  });
                                                }),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text(
                                                widget.chatData
                                                    .data()['audioName'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                                width: 120,
                                                child: Text(filesize(int.parse(
                                                    widget.chatData.data()[
                                                        'audioSize'])))),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      if (File(storagePath +
                                              "/Audios/" +
                                              widget.chatData
                                                  .data()['audioName'])
                                          .existsSync()) {
                                        OpenFile.open(storagePath +
                                            "/Audios/" +
                                            widget.chatData
                                                .data()['audioName']);
                                      }
                                    }),
                              )
                            : (widget.chatData.data()['type'] == "video"
                                ? Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(
                                            isMe ? 0.0 : borderRadius),
                                        bottomRight: Radius.circular(
                                            isMe ? 0.0 : borderRadius),
                                        topLeft: Radius.circular(
                                            isMe ? borderRadius : 0.0),
                                        bottomLeft: Radius.circular(
                                            isMe ? borderRadius : 0.0),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  SlideRightRoute(
                                                      page: VideoPlayerScreen(
                                                    title: widget.chatData
                                                            .data()['id']
                                                        ['fileName'],
                                                    video: widget.chatData
                                                            .data()['id']
                                                        ['videoURL'],
                                                  )));
                                            },
                                            child: Image(
                                              image: NetworkImage(widget
                                                  .chatData
                                                  .data()["videoThumbnail"]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            child: CupertinoButton(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black
                                                          .withOpacity(0.7)),
                                                  child: Icon(Icons
                                                      .play_arrow_outlined),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      SlideRightRoute(
                                                          page:
                                                              VideoPlayerScreen(
                                                        title: widget.chatData
                                                                .data()['id']
                                                            ['fileName'],
                                                        video: widget.chatData
                                                                .data()['id']
                                                            ['videoURL'],
                                                      )));
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : widget.chatData['type'] == "giphy"
                                    ? Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Image.network(
                                          widget.chatData.data()['giphy'],
                                          headers: {'accept': 'image/*'},
                                        ))
                                    : LinkWell(
                                        widget.chatData.data()["message"],
                                        linkStyle: GoogleFonts.roboto(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 18.0,
                                            decoration:
                                                TextDecoration.underline),
                                        style: GoogleFonts.roboto(
                                          fontSize: 18.0,
                                          color: Theme.of(context).splashColor,
                                        )))))
          ]);
    }

    return (isMe
        ? ContextualActionWidget(
            data: widget.chatData,
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: widget.chatData.data()['type'] == "image" ||
                        widget.chatData.data()['type'] == "video"
                    ? EdgeInsets.all(1.0)
                    : EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                margin: EdgeInsets.only(
                  bottom: 5.0,
                  top: 5.0,
                  left: isMe ? 100.0 : 0.0,
                  right: isMe ? 0.0 : 100.0,
                ),
                decoration: decoration,
                child: messageWidget(),
              ),
            ),
          )
        : Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: widget.chatData.data()['type'] == "image" ||
                      widget.chatData.data()['type'] == "video"
                  ? EdgeInsets.all(1.0)
                  : EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin: EdgeInsets.only(
                bottom: 5.0,
                top: 5.0,
                left: isMe ? 100.0 : 0.0,
                right: isMe ? 0.0 : 100.0,
              ),
              decoration: decoration,
              child: messageWidget(),
            ),
          ));
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';
import 'package:open_file/open_file.dart';
import 'package:sohbetapp/screens/review_pages/review_image.dart';
import 'package:sohbetapp/screens/review_pages/video_player.dart';
import 'package:sohbetapp/utilities/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

Widget messageWidget(
    bool isMe,
    BuildContext context,
    String convID,
    String messageId,
    List list,
    Map chatContents,
    DocumentSnapshot chatData,
    bool playMode,
    Function playFunction,
    Function pauseFunction) {
  final borderRadius = 20.0;
  Map<String, dynamic> answeredMessageData =
      chatContents['answeredMessageData'];
  DateFormat hoursAndMintues = DateFormat("HH:mm a");
  DateTime timestamp = chatData.data()['date'].toDate();
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
          children:
              list.contains("conversations/$convID/messages/$messageId") == null
                  ? [
                      Text(
                        chatContents['senderName'],
                        style: GoogleFonts.quicksand(
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
                          hoursAndMintues
                              .format(timestamp)
                              .toString()
                              .split(', ')[0],
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
                        chatData.data()['seenData'] == true
                            ? Icons.verified
                            : Icons.verified_outlined,
                        size: 18,
                        color: isMe
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).iconTheme.color,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    ]
                  : [
                      Text(
                        chatContents['senderName'],
                        style: GoogleFonts.quicksand(
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
                          hoursAndMintues
                              .format(timestamp)
                              .toString()
                              .split(', ')[0],
                          style: GoogleFonts.roboto(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).iconTheme.color,
                          )),
                      SizedBox(
                        width: 7,
                      ),
                      Icon(
                        chatData.data()['seenData'] == true
                            ? Icons.verified
                            : Icons.verified_outlined,
                        size: 18,
                        color: isMe
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).iconTheme.color,
                      )
                    ],
        ),
        answeredMessageData != null
            ? Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20, bottom: 10, top: 10),
                width: MediaQuery.of(context).size.width * 0.55,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      stops: [0.08, 0.08],
                      colors: isMe
                          ? [
                              Theme.of(context).accentColor,
                              Theme.of(context).primaryColor,
                            ]
                          : [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ],
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      answeredMessageData['senderName'],
                      style: GoogleFonts.roboto(
                          color: isMe
                              ? Theme.of(context).iconTheme.color
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      answeredMessageData['message'],
                      maxLines: 2,
                      style: GoogleFonts.roboto(
                          color: Theme.of(context).splashColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            : SizedBox(),
        SizedBox(height: 8),
        chatData.data()['type'] == "image"
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
                                    imageName: chatContents['fileName'],
                                    imageURL: chatContents["imageURL"],
                                  )));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInImage(
                          image: NetworkImage(chatContents["imageURL"]),
                          fit: BoxFit.cover,
                          placeholder: AssetImage('assets/gifs/loading.gif'),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: LinkWell(chatContents["message"],
                              linkStyle: GoogleFonts.quicksand(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18.0,
                                  decoration: TextDecoration.underline),
                              style: GoogleFonts.quicksand(
                                fontSize: 18.0,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : (chatData['type'] == "file"
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
                                    chatContents['fileName'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(filesize(
                                    int.parse(chatContents['fileSize']))),
                              ],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            File(storagePath +
                                        "/Files/" +
                                        chatContents['fileName'])
                                    .existsSync()
                                ? Container()
                                : IconButton(
                                    icon: Icon(Icons.cloud_download),
                                    onPressed: () async {
                                      String savedPath = storagePath +
                                          "/Files/" +
                                          chatContents['fileName'];
                                      Dio dio = Dio();
                                      await dio.download(
                                          chatContents['fileURL'], savedPath);
                                    },
                                  ),
                          ],
                        ),
                        onPressed: () {
                          if (File(storagePath +
                                  "/Files/" +
                                  chatContents['fileName'])
                              .existsSync()) {
                            OpenFile.open(storagePath +
                                "/Files/" +
                                chatContents['fileName']);
                          }
                        }),
                  )
                : (chatData.data()['type'] == "location"
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
                                      imageURL:
                                          chatContents['locationSnapshot'],
                                    )));
                              },
                              child: SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: Image.network(
                                      chatContents['locationSnapshot'])),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                                onTap: () async {
                                  await launch(
                                      "https://www.google.com.tr/maps/@${chatContents['latitude']},${chatContents['longitude']},18z");
                                },
                                child: Text(
                                  chatContents['locationName'],
                                  style: GoogleFonts.roboto(
                                      color: isMe
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).iconTheme.color,
                                      decoration: TextDecoration.underline,
                                      fontSize: 20),
                                ))
                          ],
                        ),
                      )
                    : chatData.data()['type'] == "audio"
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
                                            onPressed: playFunction,
                                            // onPressed: () async {
                                            //   await audioPlayer.play(
                                            //     chatContents['audioURL'],
                                            //   );
                                            //   setState(() {
                                            //     playMode = true;
                                            //   });
                                            // }
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.pause),
                                            onPressed: pauseFunction,
                                            // onPressed: () async {
                                            //   await audioPlayer.pause();
                                            //   setState(() {
                                            //     playMode = false;
                                            //   });
                                            // }
                                          ),
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
                                            chatContents['audioName'],
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
                                                chatContents['audioSize'])))),
                                      ],
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  if (File(storagePath +
                                          "/Audios/" +
                                          chatContents['audioName'])
                                      .existsSync()) {
                                    OpenFile.open(storagePath +
                                        "/Audios/" +
                                        chatContents['audioName']);
                                  }
                                }),
                          )
                        : (chatData.data()['type'] == "video"
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
                                                title: chatContents['fileName'],
                                                video: chatContents['videoURL'],
                                              )));
                                        },
                                        child: Image(
                                          image: NetworkImage(
                                              chatContents["videoThumbnail"]),
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
                                              child: Icon(
                                                  Icons.play_arrow_outlined),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  SlideRightRoute(
                                                      page: VideoPlayerScreen(
                                                    title: chatContents[
                                                        'fileName'],
                                                    video: chatContents[
                                                        'videoURL'],
                                                  )));
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : chatData['type'] == "giphy"
                                ? Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Image.network(
                                      chatContents['giphy'],
                                      headers: {'accept': 'image/*'},
                                    ))
                                : LinkWell(chatContents["message"],
                                    linkStyle: GoogleFonts.quicksand(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 18.0,
                                        decoration: TextDecoration.underline),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    )))))
      ]);
}

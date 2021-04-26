import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contextualactionbar/contextualactionbar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sohbetapp/core/services/encoding_decoding.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/widgets/chats/lost_message_widget.dart';
import 'package:sohbetapp/widgets/chats/message_widget.dart';
import 'package:sohbetapp/widgets/chats/system_chat_buble.dart';

class ChatBubble extends StatefulWidget {
  ChatBubble({
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

class _ChatBubbleState extends State<ChatBubble> {
  final borderRadius = 20.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String documentId = widget.chatData.data()['id'];
    var chatContents = EncodingDecodingService.decryptAndDecode(
        widget.chatData.data()['data'],
        documentId,
        widget.chatData['senderID'] ?? "System");

    bool isMe = (firebaseAuth.currentUser.uid == chatContents["senderId"]);

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
        bottomRight: Radius.circular(borderRadius),
        topLeft: Radius.circular(isMe ? borderRadius : 0.0),
        bottomLeft: Radius.circular(borderRadius),
      ),
    );

    return chatContents['senderId'] == "System"
        ? SystemChatBubble(
            chatData: chatContents,
          )
        : (isMe
            ? Padding(
                padding: EdgeInsets.only(right: 10),
                child: ContextualActionWidget(
                  data: widget.chatData,
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: widget.chatData.data()['type'] == "image" ||
                              widget.chatData.data()['type'] == "video"
                          ? EdgeInsets.all(1.0)
                          : EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                      margin: EdgeInsets.only(
                        bottom: 5.0,
                        top: 5.0,
                        left: isMe ? 100.0 : 0.0,
                        right: isMe ? 0.0 : 100.0,
                      ),
                      decoration: decoration,
                      child: widget.chatData['type'] == "lostMessage"
                          ? lostMessageWidget(
                              isMe,
                              context,
                              widget.convID,
                              widget.messageId,
                              widget.list,
                              chatContents,
                              widget.chatData,
                              playMode, () async {
                              await audioPlayer.play(
                                chatContents['audioURL'],
                              );
                              setState(
                                () {
                                  playMode = true;
                                },
                              );
                            }, () async {
                              await audioPlayer.pause();
                              setState(() {
                                playMode = false;
                              });
                            })
                          : messageWidget(
                              isMe,
                              context,
                              widget.convID,
                              widget.messageId,
                              widget.list,
                              chatContents,
                              widget.chatData,
                              playMode, () async {
                              await audioPlayer.play(
                                chatContents['audioURL'],
                              );
                              setState(
                                () {
                                  playMode = true;
                                },
                              );
                            }, () async {
                              await audioPlayer.pause();
                              setState(() {
                                playMode = false;
                              });
                            }),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: widget.chatData.data()['type'] == "image" ||
                            widget.chatData.data()['type'] == "video"
                        ? EdgeInsets.all(1.0)
                        : EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                    margin: EdgeInsets.only(
                      bottom: 5.0,
                      top: 5.0,
                      left: isMe ? 100.0 : 0.0,
                      right: isMe ? 0.0 : 100.0,
                    ),
                    decoration: decoration,
                    child: widget.chatData['type'] == "lostMessage"
                        ? lostMessageWidget(
                            isMe,
                            context,
                            widget.convID,
                            widget.messageId,
                            widget.list,
                            chatContents,
                            widget.chatData,
                            playMode, () async {
                            await audioPlayer.play(
                              chatContents['audioURL'],
                            );
                            setState(
                              () {
                                playMode = true;
                              },
                            );
                          }, () async {
                            await audioPlayer.pause();
                            setState(() {
                              playMode = false;
                            });
                          })
                        : messageWidget(
                            isMe,
                            context,
                            widget.convID,
                            widget.messageId,
                            widget.list,
                            chatContents,
                            widget.chatData,
                            playMode, () async {
                            await audioPlayer.play(
                              chatContents['audioURL'],
                            );
                            setState(
                              () {
                                playMode = true;
                              },
                            );
                          }, () async {
                            await audioPlayer.pause();
                            setState(() {
                              playMode = false;
                            });
                          }),
                  ),
                ),
              ));
  }
}

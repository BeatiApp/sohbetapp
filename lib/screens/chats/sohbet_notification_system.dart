import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contextualactionbar/contextualactionbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sohbetapp/core/services/chat_utilities_service/browser_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/viewmodels/viewmodels.dart';
import 'package:sohbetapp/widgets/back_button.dart';
import 'package:sohbetapp/widgets/chats/chat_shimmer.dart';
import 'package:sohbetapp/widgets/chats/system_chat_bubble.dart';
import 'package:sohbetapp/widgets/widgets.dart';
import '../../core/locator.dart';

class SohbetNotificationSystem extends StatefulWidget {
  const SohbetNotificationSystem({Key key}) : super(key: key);

  @override
  _SohbetNotificationSystemState createState() =>
      _SohbetNotificationSystemState();
}

class _SohbetNotificationSystemState extends State<SohbetNotificationSystem> {
  final TextEditingController _editingController = TextEditingController();

  CollectionReference _ref;
  FocusNode _focusNode;
  File chatImage;
  String browserUrl = "";
  bool isEmojiVisible = false;
  Key seperatorKey;
  bool isKeyboardVisible = false;
  int contextualCount = 0;
  AutoScrollController _scrollController = AutoScrollController();
  SharedPreferences prefs;
  Map<String, dynamic> answeredMessageData;
  DateTime searchedDateTime;
  Map<String, dynamic> userData;
  var model = getIt<ConversationModel>();
  BrowserService browserService = BrowserService();
  final _storageService = getIt<StorageService>();

  Future moveScrollPosition() async {
    await Future.delayed(Duration(milliseconds: 500)).then((value) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }

  var reachEnd = false;

  _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset == maxScroll) {
      setState(() {
        reachEnd = false;
      });
    } else {
      setState(() {
        reachEnd = true;
      });
    }
  }

  getImage() async {
    ChatSettings settings = ChatSettings();
    String filePath = await settings.getChatImage();
    setState(() {
      chatImage = File(filePath);
    });
  }

  Future<bool> onBackPress() {
    if (isEmojiVisible) {
      onBlurred();
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  Future onBlurred() async {
    if (isKeyboardVisible) {
      FocusScope.of(context).unfocus();
    }

    setState(() {
      isEmojiVisible = !isEmojiVisible;
    });
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    getImage();
    initPrefs();
    _ref = FirebaseFirestore.instance
        .collection('conversations/SohbetNotificationSystem/messages');
    _focusNode = FocusNode();
    _scrollController.addListener(_scrollListener);
    KeyboardVisibility.onChange.listen((bool event) {
      setState(() {
        this.isKeyboardVisible = event;
      });

      if (isKeyboardVisible && isEmojiVisible) {
        setState(() {
          isEmojiVisible = false;
        });
      }
    });

    moveScrollPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onEmojiSelected(String emoji) {
      setState(() {
        _editingController.text = _editingController.text + " $emoji";
      });
    }

    return WillPopScope(
      onWillPop: () {
        return onBackPress();
      },
      child: ChangeNotifierProvider(
        create: (BuildContext context) => model,
        child: ContextualScaffold<QueryDocumentSnapshot>(
          contextualAppBar: ContextualAppBar(
              counterBuilder: (itemsCount) {
                return Text("$itemsCount mesaj seçildi");
              },
              contextualActions: <ContextualAction<QueryDocumentSnapshot>>[
                ContextualAction(
                  itemsHandler: (items) async {},
                  child: Icon(Icons.delete),
                ),

                //Mesajı Kopyala
                ContextualAction(
                  itemsHandler: (items) {
                    String text = " ";
                    items.forEach((element) {
                      String data = element.data()['data'];
                      var chatContents =
                          EncodingDecodingService.decryptAndDecode(data,
                              element.data()['id'], element.data()['senderID']);
                      setState(() {
                        text = text + " " + chatContents['message'];
                      });
                    });
                    FlutterClipboard.copy(text);
                  },
                  child: Icon(Icons.copy),
                ),
                //Mesaja Cevap Ver
                ContextualAction(
                    itemsHandler: (items) {
                      var chatData = items.last.data();
                      var chatContent =
                          EncodingDecodingService.decryptAndDecode(
                              chatData['data'],
                              chatData['id'],
                              chatData['senderID']);

                      Map<String, dynamic> message = {
                        "message": chatContent['message'].isEmpty ||
                                chatContent['message'] == ""
                            ? (chatContent['fileName'].toString().trim() ??
                                chatContent['audioName'].toString().trim() ??
                                "Türü Belirlenemeyen Mesaj")
                            : chatContent['message'],
                        "senderName": chatContent['senderName'],
                        "messageDocId": items.last.id,
                        "messageId": chatData['id']
                      };
                      if (message['message'].isNotEmpty) {
                        setState(() {
                          answeredMessageData = message;
                        });
                      }
                    },
                    child: Icon(Icons.question_answer_outlined)),
                ContextualAction(
                  itemsHandler: (items) async {
                    var prefs = await SharedPreferences.getInstance();
                    List<String> messageList =
                        prefs.getStringList("favoriteMessageList") ?? [];
                    items.forEach((element) {
                      setState(() {
                        messageList.add(
                            "conversations/SohbetNotificationSystem/messages/${element.id}");
                      });
                    });

                    prefs.setStringList("favoriteMessageList", messageList);
                  },
                  child: Icon(Icons.tag_faces),
                ),
              ]),
          floatingActionButton: Visibility(
            visible: reachEnd,
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(left: 50, bottom: 60),
              child: InkWell(
                onLongPress: () async {
                  var nowDate = DateTime.now();
                  DateTime dateTime = await showDatePicker(
                      context: context,
                      firstDate: DateTime.utc(
                          nowDate.year, nowDate.month - 1, nowDate.day),
                      initialDate: nowDate,
                      lastDate: nowDate);
                  int index = await model.getMessageIndexBy(
                      dateTime, "SohbetNotificationSystem");
                  _scrollController.scrollToIndex(index,
                      preferPosition: AutoScrollPosition.middle);
                },
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    FontAwesomeIcons.angleDoubleDown,
                    size: 20,
                  ),
                  onPressed: () {
                    moveScrollPosition();
                  },
                ),
              ),
            ),
          ),
          appBar: AppBar(
            leading: backButtonWidget(context, setState),
            titleSpacing: -5,
            title: Row(
              children: <Widget>[
                Hero(
                  tag: "profileImageTag",
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    backgroundImage: AssetImage("assets/logos/logo.png"),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                AutoSizeText(
                  "Sohbet App",
                  minFontSize: 10,
                  maxFontSize: 25,
                )
              ],
            ),
          ),
          body: Container(
            decoration: chatImage == null
                ? BoxDecoration(color: Theme.of(context).accentColor)
                : BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(chatImage), fit: BoxFit.cover)),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      _focusNode.unfocus();
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(
                              "conversations/SohbetNotificationSystem/messages")
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        return !snapshot.hasData
                            ? ChatShimmer()
                            : GroupedListView(
                                addAutomaticKeepAlives: true,
                                elements: snapshot.data.docs,
                                groupBy: (element) {
                                  QueryDocumentSnapshot snapshot = element;
                                  DateTime dateTime =
                                      snapshot.data()['date'].toDate();
                                  DateFormat format = DateFormat.MMMMd('tr_TR');
                                  return format.format(dateTime);
                                },
                                controller: _scrollController,
                                groupSeparatorBuilder: (String value) {
                                  DateFormat format = DateFormat.MMMMd('tr_TR');
                                  DateTime today = DateTime.now();
                                  DateTime yesterday = DateTime(
                                      today.year, today.month, today.day - 1);
                                  String newValue =
                                      value == format.format(DateTime.now())
                                          ? "BUGÜN"
                                          : (value == format.format(yesterday)
                                              ? "DÜN"
                                              : value.replaceAll("-", " "));
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        width: 100,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          newValue,
                                          style: GoogleFonts.roboto(
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  );
                                },
                                itemBuilder:
                                    (context, QueryDocumentSnapshot element) {
                                  int index = snapshot.data.docs.indexWhere(
                                      (element2) => element2.id == element.id);
                                  return AutoScrollTag(
                                    controller: _scrollController,
                                    index: index,
                                    key: ValueKey(index),
                                    child: SystemNotificationBubble(
                                      convID: "SohbetNotificationSystem",
                                      messageId: element.id,
                                      chatData: element,
                                    ),
                                  );
                                },
                              );
                      },
                    ),
                  ),
                ),
                Consumer<ConversationModel>(
                  builder: (BuildContext context, ConversationModel value,
                      Widget child) {
                    return value.mediaPath.isEmpty
                        ? Container()
                        : CupertinoButton(
                            onPressed: () {
                              model.clearMediaPath();
                            },
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(File(value.mediaPath))),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20)),
                              alignment: Alignment.bottomRight,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                  },
                ),
                Container(
                  height: 60,
                  decoration: BoxDecoration(color: Colors.white),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      "Sohbet Güncelleme Yöneticisine mesaj gönderemezsiniz.",
                      style: GoogleFonts.roboto(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

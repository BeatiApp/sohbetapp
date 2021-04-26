import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contextualactionbar/contextualactionbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:sohbetapp/widgets/chats/answeredMessageData.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sohbetapp/core/services/chat_utilities_service/browser_service.dart';
import 'package:random_string/random_string.dart';
import 'package:sohbetapp/core/services/profileService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/calls/voice_call.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sohbetapp/screens/chats/search_messages.dart';
import 'package:sohbetapp/screens/groups/group_profile_screen.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/screens/image_edit/edit_image.dart';
import 'package:sohbetapp/screens/profile/user_profile_screen.dart';
import 'package:sohbetapp/utilities/utilities.dart';
import 'package:sohbetapp/viewmodels/viewmodels.dart';
import 'package:sohbetapp/widgets/back_button.dart';
import 'package:sohbetapp/widgets/chats/chat_shimmer.dart';
import 'package:sohbetapp/widgets/profile/profileDetailScreen.dart';
import 'package:sohbetapp/widgets/widgets.dart';
import '../../core/locator.dart';

class ConversationPage extends StatefulWidget {
  final String userId;
  final Conversation conversation;

  const ConversationPage({Key key, this.userId, this.conversation})
      : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
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
  // bool showBrowser = false;
  // bool showBeatifun = false;
  // bool showVideo = false;
  ScreenshotCallback screenshotCallback = ScreenshotCallback();
  SharedPreferences prefs;
  Map<String, dynamic> answeredMessageData;
  DateTime searchedDateTime;
  Map<String, dynamic> userData;
  var model = getIt<ConversationModel>();
  BrowserService browserService = BrowserService();
  final _storageService = getIt<StorageService>();

  Future updateArchivedData(bool data, String convID) async {
    await FirebaseFirestore.instance
        .doc("conversations/$convID")
        .update({"archived_${firebaseAuth.currentUser.uid}": data});
  }

  // toggleBrowser() {
  //   setState(() {
  //     showBrowser = !showBrowser;
  //   });
  // }

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

  saveSeenData() async {
    await model.saveSeenData(widget.conversation.id);
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

  getUserToken() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.doc("users/${widget.userId}").get();

    setState(() {
      userData = snapshot.data();
    });
  }

  Future onEmojiPressed() async {
    await SystemChannels.textInput.invokeMethod("TextInput.hide");
    await Future.delayed(Duration(milliseconds: 100));
    onBlurred();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  listenScreenshot() async {
    Profile profile = await getIt<ProfileService>()
        .getProfileInfo(firebaseAuth.currentUser.uid);
    screenshotCallback.addListener(() {
      print("detected screenshot");
      model.sendScreenshotMessage(widget.conversation.id,
          "${profile.userName} kişisi ekran görüntüsü aldı.");
    });
  }

  @override
  void initState() {
    listenScreenshot();
    // setState(() {
    //   showBrowser = widget.conversation.browserURL != null &&
    //       widget.conversation.browserURL != "https://www.google.com/";
    // });

    getImage();
    initPrefs();
    _ref = FirebaseFirestore.instance
        .collection('conversations/${widget.conversation.id}/messages');
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
    saveSeenData();
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
                  itemsHandler: (items) async {
                    Map<String, dynamic> userDatas;
                    await FirebaseFirestore.instance
                        .doc("users/${firebaseAuth.currentUser.uid}")
                        .get()
                        .then((value) {
                      userDatas = value.data();
                    });
                    items.forEach((element) async {
                      await model.updateMessage({
                        'senderId': widget.userId,
                        'senderName': userDatas['username'],
                        'answeredMessageData': null,
                        'message': "🛑 Bu Mesaj Silindi.....",
                        'timeStamp':
                            DateFormat("dd-MM-yyyy").format(DateTime.now()),
                      }, element.id, widget.conversation.id);
                    });
                  },
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
                            "conversations/${widget.conversation.id}/messages/${element.id}");
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
                      dateTime, widget.conversation.id);
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
                CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileDetailScreen(
                            tag: "profileImageTag",
                            imageURL: widget.conversation.profileImage,
                          ),
                        ));
                  },
                  child: Hero(
                    tag: "profileImageTag",
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.conversation.profileImage),
                    ),
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                InkWell(
                  onTap: () async {
                    if (widget.conversation.conversationType ==
                            ConversationType.normal_chat ||
                        widget.conversation.conversationType ==
                            ConversationType.private_chat) {
                      print(widget.conversation.userList);
                      Navigator.push(
                          context,
                          SlideRightRoute(
                              page: UserProfileScreen(
                            conv: widget.conversation,
                          )));
                    } else {
                      Navigator.push(
                          context,
                          SlideRightRoute(
                            page: GroupProfileScreen(
                              conv: widget.conversation,
                            ),
                          ));
                    }
                  },
                  child: AutoSizeText(
                    widget.conversation.name,
                    minFontSize: 10,
                    maxFontSize: 25,
                  ),
                )
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Icon(Icons.phone),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallPage(
                            channelName: widget.conversation.id,
                            role: ClientRole.Broadcaster,
                          ),
                        ));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  child: Icon(Icons.videocam),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CallPage(
                                role: ClientRole.Broadcaster,
                                channelName: "${widget.conversation.id}")));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 0) {
                      showSearch(
                          context: context,
                          delegate: SearchMessages(
                              conversation: widget.conversation));
                    }
                    // if (value == 3) {
                    //   toggleBrowser();
                    // }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: ListTile(
                          leading: Icon(Icons.search),
                          title: Text("Ara"),
                        ),
                      )
                      // PopupMenuItem(
                      //   child: ListTile(
                      //       title: Text("Beatifun ile ortak müzik paylaş"),
                      //       leading: CircleAvatar(
                      //         backgroundImage:
                      //             AssetImage("assets/logos/beatifun-logo.png"),
                      //       )),
                      // ),
                      // PopupMenuItem(
                      //   child: ListTile(
                      //       title: Text("Youtube ile ortak video başlat"),
                      //       leading: CircleAvatar(
                      //         backgroundImage:
                      //             AssetImage("assets/logos/youtube-logo.png"),
                      //       )),
                      // ),
                      // PopupMenuItem(
                      //   value: 3,
                      //   child: ListTile(
                      //       title: Text("Ortak tarayıcı başlat"),
                      //       leading: CircleAvatar(
                      //         backgroundImage:
                      //             AssetImage("assets/logos/browser-icon.jpg"),
                      //       )),
                      // ),
                    ];
                  },
                  child: Icon(Icons.more_vert),
                ),
              )
            ],
          ),
          body: Container(
            decoration: chatImage == null
                ? BoxDecoration(color: Theme.of(context).accentColor)
                : BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(chatImage), fit: BoxFit.cover)),
            child: Column(
              children: <Widget>[
                // showBrowser
                //     ? (widget.conversation.browserURL == "NON-ID"
                //         ? Browser(
                //             toggleBrowser: toggleBrowser,
                //             convId: widget.conversation.id,
                //           )
                //         : Browser(
                //             initURL: widget.conversation.browserURL,
                //             toggleBrowser: toggleBrowser,
                //             convId: widget.conversation.id,
                //           ))
                //     : SizedBox.shrink(),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      _focusNode.unfocus();
                    },
                    child: StreamBuilder(
                      stream: model.getConversation(widget.conversation.id),
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
                                  List<String> messageList =
                                      prefs.getStringList(
                                              'favoriteMessageList') ??
                                          [''];
                                  int index = snapshot.data.docs.indexWhere(
                                      (element2) => element2.id == element.id);
                                  return AutoScrollTag(
                                    controller: _scrollController,
                                    index: index,
                                    key: ValueKey(index),
                                    child: ChatBubble(
                                      convID: widget.conversation.id,
                                      list: messageList,
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
                answeredMessageData != null
                    ? AnsweredMessageWidget(
                        answeredMessageData: answeredMessageData,
                        closeFunction: () {
                          setState(() {
                            answeredMessageData = null;
                          });
                        },
                      )
                    : Container(),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      height: 50,
                      margin: EdgeInsets.all(7.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                          right: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          CupertinoButton(
                            onPressed: () async {
                              await onEmojiPressed();
                            },
                            child: Icon(
                              isEmojiVisible == false
                                  ? Icons.emoji_emotions_outlined
                                  : Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: TextField(
                              style: GoogleFonts.quicksand(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              focusNode: _focusNode,
                              controller: _editingController,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) async {
                                updateArchivedData(
                                    false, widget.conversation.id);
                                if (_editingController.text.isNotEmpty) {
                                  Map<String, dynamic> userDatas;
                                  await FirebaseFirestore.instance
                                      .doc(
                                          "users/${firebaseAuth.currentUser.uid}")
                                      .get()
                                      .then((value) {
                                    userDatas = value.data();
                                  });
                                  await model.addTextMessage({
                                    'answeredMessageData': answeredMessageData,
                                    'senderId': widget.userId,
                                    'senderName': userDatas['username'],
                                    "senderProfile": userDatas['profileImage'],
                                    'message': _editingController.text,
                                    'timeStamp': DateFormat("dd-MM-yyyy")
                                        .format(DateTime.now()),
                                  }, userDatas['token']);
                                  await model.updateDisplayMessage(
                                      widget.conversation.id,
                                      _editingController.text,
                                      widget.conversation);
                                  moveScrollPosition();

                                  setState(() {
                                    answeredMessageData = null;
                                  });
                                  _editingController.text = '';
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Mesaj Yaz...",
                                hintStyle: GoogleFonts.quicksand(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          InkWell(
                            child: Icon(
                              Icons.add_box,
                              size: 30,
                            ),
                            onTap: () async {
                              showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20))),
                                context: context,
                                builder: (context) {
                                  return Container(
                                    decoration: BoxDecoration(),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 15,
                                      children: [
                                        MessageTypeButton(
                                          assetImagePath: fileIcon,
                                          buttonName: "Dosya",
                                          onPressed: () async {
                                            Map mediaURL = await model
                                                .uploadMedia(FileType.custom);
                                            Map<String, dynamic> userDatas;
                                            await FirebaseFirestore.instance
                                                .doc(
                                                    "users/${firebaseAuth.currentUser.uid}")
                                                .get()
                                                .then((value) {
                                              userDatas = value.data();
                                            });
                                            updateArchivedData(
                                                false, widget.conversation.id);

                                            await model.addFileMessage({
                                              'senderId': widget.userId,
                                              'senderName':
                                                  userDatas['username'],
                                              'fileName': mediaURL['fileName'],
                                              'fileSize': mediaURL['fileSize'],
                                              "senderProfile":
                                                  userDatas['profileImage'],
                                              'timeStamp':
                                                  DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.now()),
                                              'fileURL': mediaURL['url'],
                                            }, userDatas['token']);

                                            await model.updateDisplayMessage(
                                                widget.conversation.id,
                                                "📁 Bir Dosya Gönderildi...",
                                                widget.conversation);

                                            moveScrollPosition();
                                          },
                                        ),
                                        MessageTypeButton(
                                          assetImagePath: locationIcon,
                                          buttonName: "Konum",
                                          onPressed: () async {
                                            Map<String, dynamic> userDatas;
                                            await FirebaseFirestore.instance
                                                .doc(
                                                    "users/${firebaseAuth.currentUser.uid}")
                                                .get()
                                                .then((value) {
                                              userDatas = value.data();
                                            });
                                            updateArchivedData(
                                                false, widget.conversation.id);
                                            LocationPermission permission =
                                                await Geolocator
                                                    .checkPermission();
                                            if (permission ==
                                                LocationPermission.denied) {
                                              await Geolocator
                                                  .requestPermission();
                                            }
                                            if (await Permission
                                                .storage.isDenied) {
                                              await Permission.storage
                                                  .request();
                                            }

                                            LocationResult result =
                                                await showLocationPicker(
                                              context,
                                              googleMapsAPI,
                                              appBarColor: Theme.of(context)
                                                  .primaryColor,
                                              countries: ['TR'],
                                              myLocationButtonEnabled: true,
                                              layersButtonEnabled: true,
                                              language: "tr_TR",
                                            );

                                            String locationURL =
                                                "https://maps.googleapis.com/maps/api/staticmap?zoom=14.5&size=512x512&maptype=normal&markers=color:red|label:S|${result.latLng.latitude},${result.latLng.longitude}&key=$mapsWebApi&map_id=${randomAlphaNumeric(16)}";
                                            Dio dio = Dio();
                                            String path = storagePath +
                                                "/Locations/" +
                                                "SOHBET-LOCATION-LAT-${result.latLng.latitude}-LNG-${result.latLng.longitude}.png";

                                            await dio.download(
                                                locationURL, path);
                                            Map mapUrl = await _storageService
                                                .uploadMedia(File(path));
                                            updateArchivedData(
                                                false, widget.conversation.id);

                                            await model.addLocationMessage({
                                              'senderId': widget.userId,
                                              'senderName':
                                                  userDatas['username'],
                                              "senderProfile":
                                                  userDatas['profileImage'],
                                              'message':
                                                  _editingController.text,
                                              'locationSnapshot': mapUrl['url'],
                                              'locationName': result.address ??
                                                  "Yeni Konum",
                                              'timeStamp':
                                                  DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.now()),
                                            }, userDatas['token']);

                                            await model.updateDisplayMessage(
                                                widget.conversation.id,
                                                "📌 Bir Konum Gönderildi...",
                                                widget.conversation);

                                            moveScrollPosition();
                                          },
                                        ),
                                        MessageTypeButton(
                                          assetImagePath: cameraIcon,
                                          buttonName: "Kamera",
                                          onPressed: () async {
                                            Map imageURL = await model
                                                .uploadMediaFromCamera(context);
                                            Map<String, dynamic> userDatas;
                                            await FirebaseFirestore.instance
                                                .doc(
                                                    "users/${firebaseAuth.currentUser.uid}")
                                                .get()
                                                .then((value) {
                                              userDatas = value.data();
                                            });
                                            await model.addImageMessage({
                                              'senderId': widget.userId,
                                              'senderName':
                                                  userDatas['username'],
                                              "senderProfile":
                                                  userDatas['profileImage'],
                                              'message':
                                                  _editingController.text,
                                              'timeStamp':
                                                  DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.now()),
                                              'imageURL': imageURL['url'],
                                              'fileName': imageURL['fileName'],
                                              'fileSize': imageURL['fileSize']
                                            }, userDatas['token'],
                                                widget.conversation.id);
                                            updateArchivedData(
                                                false, widget.conversation.id);
                                            await model.updateDisplayMessage(
                                                widget.conversation.id,
                                                "📷 Bir Resim Gönderildi...",
                                                widget.conversation);
                                            moveScrollPosition();
                                          },
                                        ),
                                        MessageTypeButton(
                                          assetImagePath: micIcon,
                                          buttonName: "Ses Dosyası",
                                          onPressed: () async {
                                            var map = await model
                                                .uploadMedia(FileType.audio);
                                            Map<String, dynamic> userDatas;
                                            await FirebaseFirestore.instance
                                                .doc(
                                                    "users/${firebaseAuth.currentUser.uid}")
                                                .get()
                                                .then((value) {
                                              userDatas = value.data();
                                            });
                                            updateArchivedData(
                                                false, widget.conversation.id);
                                            await model.addAudioMessage({
                                              'senderId': widget.userId,
                                              'senderName':
                                                  userDatas['username'],
                                              "senderProfile":
                                                  userDatas['profileImage'],
                                              'message':
                                                  _editingController.text,
                                              'timeStamp':
                                                  DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.now()),
                                              'audioURL': map['url'],
                                              'audioSize': map['fileSize'],
                                              'audioName': map['fileName']
                                            }, userDatas['token']);

                                            await model.updateDisplayMessage(
                                                widget.conversation.id,
                                                "🔊 Bir Ses Kaydı Gönderildi...",
                                                widget.conversation);

                                            moveScrollPosition();
                                          },
                                        ),
                                        MessageTypeButton(
                                          assetImagePath: galleryIcon,
                                          buttonName: "Galeri",
                                          onPressed: () async {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditImage(
                                                    conversation:
                                                        widget.conversation,
                                                    userId: firebaseAuth
                                                        .currentUser.uid,
                                                    imageName: "Resim Gönder",
                                                  ),
                                                ));
                                            moveScrollPosition();
                                          },
                                        ),
                                        MessageTypeButton(
                                          assetImagePath: videoIcon,
                                          buttonName: "Video",
                                          onPressed: () async {
                                            Map videoURL = await model
                                                .uploadMedia(FileType.video);
                                            Map<String, dynamic> userDatas;
                                            await FirebaseFirestore.instance
                                                .doc(
                                                    "users/${firebaseAuth.currentUser.uid}")
                                                .get()
                                                .then((value) {
                                              userDatas = value.data();
                                            });
                                            updateArchivedData(
                                                false, widget.conversation.id);
                                            await model.addVideoMessage({
                                              'senderId': widget.userId,
                                              'senderName':
                                                  userDatas['username'],
                                              "senderProfile":
                                                  userDatas['profileImage'],
                                              'message':
                                                  _editingController.text,
                                              'timeStamp':
                                                  DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.now()),
                                              'videoURL': videoURL['url'],
                                              'fileName': videoURL['fileName'],
                                              'fileSize': videoURL['fileSize'],
                                              'videoThumbnail':
                                                  videoURL['thumbnail']
                                            }, userDatas['token']);

                                            await model.updateDisplayMessage(
                                                widget.conversation.id,
                                                "🎬 Bir Video Gönderildi...",
                                                widget.conversation);

                                            moveScrollPosition();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.gif_outlined,
                              size: 35,
                            ),
                            onPressed: () async {
                              GiphyGif gif = await GiphyGet.getGif(
                                context: context, //Required
                                apiKey: giphyAPI, //Required.
                                lang: GiphyLanguage
                                    .turkish, //Optional - Language for query.
                                randomID: firebaseAuth.currentUser
                                    .uid, // Optional - An ID/proxy for a specific user.
                                searchText:
                                    "GIPHY'de Ara..", //Optional - AppBar search hint text.
                                tabColor: Colors
                                    .teal, // Optional- default accent color.
                              );
                              Map<String, dynamic> userDatas;
                              await FirebaseFirestore.instance
                                  .doc("users/${firebaseAuth.currentUser.uid}")
                                  .get()
                                  .then((value) {
                                userDatas = value.data();
                              });
                              if (gif != null) {
                                model.addGifMessage({
                                  'senderId': widget.userId,
                                  'senderName': userDatas['username'],
                                  "senderProfile": userDatas['profileImage'],
                                  'message': _editingController.text,
                                  'giphy': gif.images.original.webp,
                                  'giphyName': gif.title,
                                  'timeStamp': DateFormat("dd-MM-yyyy")
                                      .format(DateTime.now()),
                                }, userDatas['token']);

                                await model.updateDisplayMessage(
                                    widget.conversation.id,
                                    "🙂 Bir Gif Gönderildi...",
                                    widget.conversation);
                                moveScrollPosition();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onDoubleTap: () async {
                        updateArchivedData(false, widget.conversation.id);
                        if (_editingController.text.isNotEmpty) {
                          Map<String, dynamic> userDatas;
                          await FirebaseFirestore.instance
                              .doc("users/${firebaseAuth.currentUser.uid}")
                              .get()
                              .then((value) {
                            userDatas = value.data();
                          });
                          await model.addLostTextMessage({
                            'answeredMessageData': answeredMessageData,
                            'senderId': widget.userId,
                            'senderName': userDatas['username'],
                            "senderProfile": userDatas['profileImage'],
                            'message': _editingController.text,
                            'timeStamp':
                                DateFormat("dd-MM-yyyy").format(DateTime.now()),
                          });
                          await model.updateDisplayMessage(
                              widget.conversation.id,
                              "İmha Eden Mesaj Gönderildi",
                              widget.conversation);
                          moveScrollPosition();

                          setState(() {
                            answeredMessageData = null;
                          });
                          _editingController.text = '';
                        }
                      },
                      onTap: () async {
                        updateArchivedData(false, widget.conversation.id);
                        if (_editingController.text.isNotEmpty) {
                          Map<String, dynamic> userDatas;
                          await FirebaseFirestore.instance
                              .doc("users/${firebaseAuth.currentUser.uid}")
                              .get()
                              .then((value) {
                            userDatas = value.data();
                          });
                          await model.addTextMessage({
                            'answeredMessageData': answeredMessageData,
                            'senderId': widget.userId,
                            'senderName': userDatas['username'],
                            "senderProfile": userDatas['profileImage'],
                            'message': _editingController.text,
                            'timeStamp':
                                DateFormat("dd-MM-yyyy").format(DateTime.now()),
                          }, userDatas['token']);
                          await model.updateDisplayMessage(
                              widget.conversation.id,
                              _editingController.text,
                              widget.conversation);
                          moveScrollPosition();

                          setState(() {
                            answeredMessageData = null;
                          });
                          _editingController.text = '';
                        }
                      },
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        margin: EdgeInsets.only(right: 5),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        // ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            sendIcon,
                            width: 30,
                            height: 30,
                            color: Theme.of(context).splashColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Offstage(
                    offstage: !isEmojiVisible,
                    child: EmojiPickerWidget(onEmojiSelected: onEmojiSelected))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String printHoursAndMinit(Timestamp timestamp) {
  DateFormat dateFormat = DateFormat("HH:mm a");
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
  String date = dateFormat.format(dateTime);
  return date;
}

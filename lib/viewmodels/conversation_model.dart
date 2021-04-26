import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:sohbetapp/core/services/encoding_decoding.dart';
import 'package:sohbetapp/core/services/messaging_service.dart';
import 'package:sohbetapp/core/services/storage_service.dart';
import 'package:sohbetapp/models/conversation_type.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/utilities/sensitive_constants.dart';

import '../core/locator.dart';
import 'base_model.dart';

class ConversationModel extends BaseModel {
  final StorageService _storageService = getIt<StorageService>();
  CollectionReference _ref;
  Map<String, dynamic> fileMetaData;
  String mediaPath = "";
  MessagingService messagingService = MessagingService();

  Future<int> getMessageIndexBy(DateTime dateTime, String convID) async {
    var data = await FirebaseFirestore.instance
        .collection("conversations/$convID/messages")
        .get();
    return data.docs
        .indexWhere((element) => element.data()['date'].toDate() == dateTime);
  }

  Future sendScreenshotMessage(String convId, String message) async {
    var id = randomAlphaNumeric(26);
    var doc = FirebaseFirestore.instance
        .collection("conversations/$convId/messages")
        .doc();
    Map<String, dynamic> data = {
      "message": message,
      "senderId": "System",
      "type": "text",
      "answeredMessageData": null,
      "senderName": "Sohbet App System",
      'timeStamp': DateFormat("dd-MM-yyyy").format(DateTime.now())
    };

    String encryptedData =
        EncodingDecodingService.encodeAndEncrypt(data, id, "System");

    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "text",
      "senderID": "System",
      "date": DateTime.now(),
      "seenData": false
    });
  }

  getUnreadedMessages(String conversationID) async {
    var docs = await FirebaseFirestore.instance
        .collection("conversations/$conversationID/messages")
        .where("seenData", isEqualTo: false)
        .get();
    List documentList = docs.docs.where((element) {
      Map<String, dynamic> datas = EncodingDecodingService.decryptAndDecode(
          element.data()['data'],
          element.data()['id'],
          element.data()['senderID']);
      return datas['senderId'] != firebaseAuth.currentUser.uid;
    }).toList();
    return documentList.length;
  }

  Future updateArchivedData(bool data, String convID) async {
    await FirebaseFirestore.instance
        .doc("conversations/$convID")
        .update({"archived": data});
  }

  addImageMessage(
      Map<String, dynamic> data, String token, String convID) async {
    mediaPath = "";
    var id = randomAlphaNumeric(26);
    var doc = FirebaseFirestore.instance
        .collection("conversations/$convID/messages")
        .doc();
    print(doc.id);
    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);
    await messagingService.sendAndRetrieveMessage(
        "Yeni Bir Resim Aldınız...", data['senderName'], token);
    notifyListeners();

    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "image",
      "senderID": firebaseAuth.currentUser.uid,
      "date": DateTime.now(),
      "seenData": false
    });
  }

  addGifMessage(Map<String, dynamic> data, String token) async {
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data, id, firebaseAuth.currentUser.uid // using doc id as IV
        );
    await messagingService.sendAndRetrieveMessage(
        "Yeni Bir Gif Aldınız...", data['senderName'], token);
    notifyListeners();

    doc.set({
      "data": encryptedData,
      "senderID": firebaseAuth.currentUser.uid,
      "id": id,
      "type": "giphy",
      "date": DateTime.now(),
      "seenData": false
    });
  }

  addVideoMessage(Map<String, dynamic> data, String token) async {
    mediaPath = "";
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);
    await messagingService.sendAndRetrieveMessage(
        "Yeni Bir Video Aldınız...", data['senderName'], token);
    notifyListeners();

    doc.set({
      "data": encryptedData,
      "id": id,
      "senderID": firebaseAuth.currentUser.uid,
      "type": "video",
      "date": DateTime.now(),
      "seenData": false
    });
  }

  addLocationMessage(Map<String, dynamic> data, String token) async {
    mediaPath = "";
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);
    await messagingService.sendAndRetrieveMessage(
        "Yeni Bir Konum Aldınız...", data['senderName'], token);
    notifyListeners();

    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "location",
      "senderID": firebaseAuth.currentUser.uid,
      "date": DateTime.now(),
      "seenData": false
    });
  }

  addFileMessage(Map<String, dynamic> data, String token) async {
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);
    await messagingService.sendAndRetrieveMessage(
        "Yeni Bir Dosya Aldınız...", data['senderName'], token);
    notifyListeners();

    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "file",
      "senderID": firebaseAuth.currentUser.uid,
      "date": DateTime.now(),
      "seenData": false
    });
  }

  addAudioMessage(Map<String, dynamic> data, String token) async {
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);
    await messagingService.sendAndRetrieveMessage(
        "Yeni Bir Ses Dosyası Aldınız...", data['senderName'], token);
    notifyListeners();

    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "audio",
      "senderID": firebaseAuth.currentUser.uid,
      "date": DateTime.now(),
      "seenData": false
    });
  }

  updateDisplayMessage(
      String convID, String displayMessage, Conversation conv) async {
    DateFormat dateFormat = DateFormat('HH:mm a');
    Map<String, dynamic> data = {
      "displayMessage": displayMessage,
      "displayMessageDate": dateFormat.format(DateTime.now())
    };
    String displayMessageData =
        conv.conversationType == ConversationType.normal_chat ||
                conv.conversationType == ConversationType.private_chat
            ? EncodingDecodingService.encodeAndEncrypt(data, convID, convID)
            : EncodingDecodingService.encodeAndEncrypt(
                data, convID, conv.groupOwner);
    await FirebaseFirestore.instance
        .doc("conversations/$convID")
        .update({"displayMessageData": displayMessageData});
  }

  Stream<QuerySnapshot> getConversation(String id) {
    _ref = FirebaseFirestore.instance.collection('conversations/$id/messages');
    return _ref.orderBy('date', descending: false).snapshots();
  }

  Future addTextMessage(Map<String, dynamic> data, String token) async {
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);

    notifyListeners();
    await messagingService.sendAndRetrieveMessage(
        data['message'], data['senderName'], token);
    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "text",
      "senderID": firebaseAuth.currentUser.uid,
      "date": DateTime.now(),
      "seenData": false
    });
  }

  Future addLostTextMessage(Map<String, dynamic> data) {
    var id = randomAlphaNumeric(26);
    var doc = _ref.doc();

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);

    notifyListeners();

    doc.set({
      "data": encryptedData,
      "id": id,
      "type": "lostMessage",
      "senderID": firebaseAuth.currentUser.uid,
      "date": DateTime.now(),
      "seenData": false
    });
  }

  Future saveSeenData(String convID) async {
    var data = await FirebaseFirestore.instance
        .collection("conversations/$convID/messages")
        .get();
    data.docs.forEach((element) async {
      String messageData = element.data()['data'];
      Map<String, dynamic> map = EncodingDecodingService.decryptAndDecode(
          messageData, element.data()['id'], element.data()['senderID']);
      if (map['senderId'] != firebaseAuth.currentUser.uid &&
          element.data()["seenData"] != true) {
        await FirebaseFirestore.instance
            .doc("conversations/$convID/messages/${element.id}")
            .update({"seenData": true});
      }
    });
  }

  Future<Map<String, dynamic>> uploadAudioMessage(BuildContext context) async {
    bool hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission == false) {
      await Permission.microphone.request();
    }
    DateFormat format = DateFormat.yMMMd('tr_TR');
    if (!Directory(storagePath + "/Audios").existsSync()) {
      Directory(storagePath + "/Audios").createSync();
    }
    Map data;
    String path = storagePath +
        "/Audios/" +
        "SOHBET-MEDIA-AUDIO-${firebaseAuth.currentUser.uid}-${format.format(DateTime.now())}.wav";
    var recorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.WAV);
    await recorder.initialized;
    bool recordState = false;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Text("Ses Kaydetmek İçin aşağıdaki butona basınız tutun"),
              SizedBox(
                height: 15,
              ),
              CupertinoButton(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor),
                  child: Icon(
                    recordState == false ? Icons.mic : Icons.stop,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                onPressed: () async {
                  if (recordState == false) {
                    await recorder.start();
                  } else {
                    Recording recording = await recorder.stop();
                    data =
                        await _storageService.uploadMedia(File(recording.path));
                  }
                  return data;
                },
              )
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26), topRight: Radius.circular(26))),
        );
      },
    );
  }

  Future<DocumentReference> updateMessage(
      Map<String, dynamic> data, String messageId, String convID) async {
    var id = randomAlphaNumeric(26);
    var firestore = FirebaseFirestore.instance
        .doc("conversations/$convID/messages/$messageId");

    String encryptedData = EncodingDecodingService.encodeAndEncrypt(
        data,
        id, // using doc id as IV
        firebaseAuth.currentUser.uid);

    notifyListeners();

    firestore.update({"data": encryptedData, "id": id, "type": "text"});
  }

  Future<Map<String, dynamic>> uploadMedia(FileType type) async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (!Directory(storagePath + "/Videos/").existsSync()) {
      await Directory(storagePath + "/Videos/").create();
    }
    var result = type == FileType.custom
        ? await FilePicker.getFile(allowedExtensions: [
            'jpg',
            'png',
            'gif',
            'txt',
            'doc',
            'pdf',
            'mp4',
            'mp3',
            'wav',
            'rar',
            'zip'
          ], type: FileType.custom)
        : await FilePicker.getFile(type: type);

    var pickedFile = File(result.path);
    pickedFile.copySync(type == FileType.video
        ? storagePath + "/Videos/" + basename(pickedFile.path)
        : (type == FileType.audio
            ? storagePath + "/Audios/" + basename(pickedFile.path)
            : storagePath + "/Files/" + basename(pickedFile.path)));
    fileMetaData = type == FileType.video
        ? await _storageService.uploadVideo(File(pickedFile.path))
        : await _storageService.uploadMedia(File(pickedFile.path));

    notifyListeners();
    return fileMetaData;
  }

  Future<Map<String, dynamic>> uploadMediaFromCamera(
      BuildContext context) async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    mediaPath = pickedFile.path;
    File(pickedFile.path)
        .copySync(storagePath + "/Images/" + basename(pickedFile.path));

    fileMetaData = await _storageService.uploadMedia(File(pickedFile.path));

    notifyListeners();
    return fileMetaData;
  }

  Future<Map<String, dynamic>> uploadMediaFromGallery(
      BuildContext context, PickedFile pickedFile) async {
    mediaPath = pickedFile.path;
    fileMetaData = await _storageService.uploadMedia(File(pickedFile.path));
    File(pickedFile.path)
        .copySync(storagePath + "/Images/" + basename(pickedFile.path));

    notifyListeners();
    return fileMetaData;
  }

  clearMediaPath() {
    mediaPath = "";
    notifyListeners();
  }
}

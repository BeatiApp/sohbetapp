import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/core/services/chat_service.dart';
import 'package:sohbetapp/core/services/profileService.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'package:sohbetapp/models/conversation_type.dart';
import 'package:sohbetapp/models/profile.dart';
import 'package:sohbetapp/screens/chats/conversation_page.dart';
import 'package:sohbetapp/utilities/right_page_route.dart';
import 'package:sohbetapp/viewmodels/base_model.dart';

class ContactsModel extends BaseModel {
  final ChatService _chatService = getIt<ChatService>();
  final StorageService storageService = getIt<StorageService>();
  final ProfileService profileService = getIt<ProfileService>();

  Future<List<Profile>> getContacts() async {
    // await FlutterContacts.getContacts(withPhotos: true).then((element) {
    //   element.forEach((em) {
    //     contactList.add(em.phones.first.number);
    //   });
    // });
    var contacts = await _chatService.getContacs();
    print(contacts);
    var filteredContacts = contacts
        /*.where(
          (profile) =>
              profile.userName.startsWith(query ?? new RegExp(r'[A-Z][a-z]')),
        )*/
        // .where((element) => (contactList.contains(element.phoneNumber)))
        .toList();
    print(filteredContacts);
    return filteredContacts;
  }

  Future<List<Profile>> getContactsQuery(String query) async {
    List<String> contactList = [];
    // await FlutterContacts.getContacts(withPhotos: true).then((element) {
    //   element.forEach((em) {
    //     contactList.add(em.phones.first.number);
    //   });
    // });
    var contacts = await _chatService.getContacsQuery(query);

    var filteredContacts = contacts.where(
      (profile) {
        return profile.usernameQuery.contains(query);
      },
    )
        // .where((element) => (contactList.contains(element.phoneNumber)))
        .toList();

    return filteredContacts;
  }

  void startGroupConversation(User ownerUser, List<Profile> profile,
      BuildContext context, ConversationType conversationType) async {
    String type;

    switch (conversationType) {
      case ConversationType.group_chat:
        type = "group_chat";
        break;
      case ConversationType.private_chat:
        type = "private_chat";
        break;
      case ConversationType.private_group:
        type = "private_group";
        break;
      case ConversationType.normal_chat:
        type = "normal_chat";
        break;
      default:
    }

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.doc("users/${ownerUser.uid}").get();
    DocumentSnapshot storiesSnapshot =
        await FirebaseFirestore.instance.doc("users/${ownerUser.uid}").get();
    Profile ownerProfile = Profile.fromSnapshot(snapshot);
    profile.add(ownerProfile);
    List<String> memberList = [];
    profile.forEach((element) {
      memberList.add(element.id);
    });
    if (conversationType == ConversationType.group_chat) {
      await showDialog(
        context: context,
        builder: (context) {
          File imageFile;
          TextEditingController controller = TextEditingController();
          return AlertDialog(
            content: Container(
              height: 200,
              child: Form(
                child: Column(
                  children: [
                    Text(
                      "Grubunuza bir isim belirleyin ve arkadaşlarınızla Sohbet'in keyfini çıkarın! 😉",
                      style: GoogleFonts.roboto(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    imageFile == null
                        ? GestureDetector(
                            onTap: () async {
                              PickedFile pickedFile = await ImagePicker()
                                  .getImage(source: ImageSource.gallery);
                              imageFile = File(pickedFile.path);
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300]),
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 25,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(imageFile))),
                          ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Grup İsmi",
                        suffixIcon: Icon(Icons.group),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: () async {
                  Map urlData = await storageService.uploadMedia(imageFile);
                  var conversation = await _chatService.startNewGroup(
                      memberList,
                      context,
                      type,
                      controller.text ?? "İsimsiz Grup",
                      urlData['url']);

                  Navigator.of(context).pushReplacement(SlideRightRoute(
                      page: ConversationPage(
                    conversation: conversation,
                    userId: ownerProfile.id,
                  )));
                },
                color: Colors.blue,
                child: Text("DEVAM ET"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.red,
                child: Text("IPTAL ET"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ],
          );
        },
      );
    } else if (conversationType == ConversationType.private_group) {
      await showDialog(
        context: context,
        builder: (context) {
          File imageFile;
          TextEditingController controller = TextEditingController();
          TextEditingController passController = TextEditingController();
          return AlertDialog(
            content: Container(
              height: 300,
              child: Form(
                child: Column(
                  children: [
                    Text(
                      "Grubunuza isim ve şifre belirleyin ve arkadaşlarınızla Sohbet'in keyfini çıkarın! 😉",
                      style: GoogleFonts.roboto(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    imageFile == null
                        ? GestureDetector(
                            onTap: () async {
                              PickedFile pickedFile = await ImagePicker()
                                  .getImage(source: ImageSource.gallery);
                              imageFile = File(pickedFile.path);
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300]),
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 25,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(imageFile))),
                          ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Grup İsmi",
                        suffixIcon: Icon(Icons.group),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Grup Şifresi",
                        suffixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: () async {
                  Map urlData = await storageService.uploadMedia(imageFile);
                  String passHash =
                      EncryptionService.generateMD5Hash(passController.text);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var conversation = await _chatService.startNewGroup(
                      memberList,
                      context,
                      type,
                      controller.text ?? "İsimsiz Grup",
                      urlData['url']);
                  prefs.setString(conversation.id, passHash);
                  Navigator.of(context).pushReplacement(SlideRightRoute(
                      page: ConversationPage(
                    conversation: conversation,
                    userId: ownerProfile.id,
                  )));
                },
                color: Colors.blue,
                child: Text("DEVAM ET"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.red,
                child: Text("IPTAL ET"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ],
          );
        },
      );
    }
  }

  void startConversation(User user, Profile profile, BuildContext context,
      ConversationType conversationType) async {
    String type;

    switch (conversationType) {
      case ConversationType.group_chat:
        type = "group_chat";
        break;
      case ConversationType.private_chat:
        type = "private_chat";
        break;
      case ConversationType.private_group:
        type = "private_group";
        break;
      case ConversationType.normal_chat:
        type = "normal_chat";
        break;
      default:
    }

    if (conversationType == ConversationType.normal_chat) {
      var data = await FirebaseFirestore.instance
          .collection("conversations")
          .where("members", isEqualTo: [user.uid, profile.id]).get();
      if (data.docs.length == 0) {
        var conversation = await _chatService.startConversation(
          user,
          profile,
          context,
          type,
        );

        Navigator.of(context).pushReplacement(SlideRightRoute(
            page: ConversationPage(
          conversation: conversation,
          userId: user.uid,
        )));
      } else {
        QueryDocumentSnapshot snapshot = data.docs.first;

        Conversation conv =
            Conversation.fromSnapshot(snapshot, 0, profile: profile);
        Navigator.of(context).pushReplacement(SlideRightRoute(
            page: ConversationPage(
          conversation: conv,
          userId: user.uid,
        )));
      }
    } else if (conversationType == ConversationType.private_chat) {
      await showDialog(
        context: context,
        builder: (context) {
          TextEditingController controller = TextEditingController();
          return AlertDialog(
            content: Container(
              height: 150,
              child: Form(
                child: Column(
                  children: [
                    Text(
                      "Tüm Sohbetlerin şifrelenir ama gizli sohbetler %100 güvenli! 🕵\n Eğer şifre koymazsam şifren otomatik olarak 12345 olarak değiştirilir.",
                      style: GoogleFonts.roboto(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: "Gizli Sohbet Şifresi",
                        suffixIcon: Icon(Icons.lock),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var conversation = await _chatService.startConversation(
                    user,
                    profile,
                    context,
                    type,
                    /*controller.text ?? "İsimsiz Grup",
                      "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png"*/
                  );
                  prefs.setString(
                      conversation.id,
                      EncryptionService.generateMD5Hash(
                          controller.text ?? "12345"));

                  Navigator.of(context).pushReplacement(SlideRightRoute(
                      page: ConversationPage(
                    conversation: conversation,
                    userId: user.uid,
                  )));
                },
                color: Colors.blue,
                child: Text("DEVAM ET"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.red,
                child: Text("IPTAL ET"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ],
          );
        },
      );
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/core/services/encoding_decoding.dart';
import 'package:sohbetapp/core/services/profileService.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'package:sohbetapp/models/profile.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileService profileService = getIt<ProfileService>();
  Stream<List<Conversation>> getConversations(String userId) {
    var ref = _firestore
        .collection('conversations')
        .where('members', arrayContains: userId)
        .where('archived_${firebaseAuth.currentUser.uid}', isEqualTo: false);

    var convsersationsStream = ref.snapshots();

    var profilesStream = getContacs().asStream();

    return Rx.combineLatest2(
      convsersationsStream,
      profilesStream,
      (QuerySnapshot conversations, List<Profile> profiles) =>
          conversations.docs.map(
        (snapshot) {
          List<String> members = List.from(snapshot['members']);

          var profile = profiles.firstWhere(
            (element) =>
                element.id == members.firstWhere((member) => member != userId),
          );
          return Conversation.fromSnapshot(snapshot, 0, profile: profile);
        },
      ).toList(),
    );
  }

  Stream<List<Conversation>> getConversationsQuery(
      String userId, String query) {
    var ref = _firestore
        .collection('conversations')
        .where('members', arrayContains: userId)
        .where("groupName", isGreaterThanOrEqualTo: query);
    var convsersationsStream = ref.snapshots();

    var profilesStream = getContacs().asStream();

    return Rx.combineLatest2(
      convsersationsStream,
      profilesStream,
      (QuerySnapshot conversations, List<Profile> profiles) =>
          conversations.docs.map(
        (snapshot) {
          List<String> members = List.from(snapshot['members']);

          var profile = profiles.firstWhere(
            (element) =>
                element.id == members.firstWhere((member) => member != userId),
          );

          var convData =
              Conversation.fromSnapshot(snapshot, 0, profile: profile);

          return convData;
        },
      ).toList(),
    );
  }

  Stream<List<Conversation>> getArchivedConversations(String userId) {
    var ref = _firestore
        .collection('conversations')
        .where('members', arrayContains: userId)
        .where('archived_${firebaseAuth.currentUser.uid}', isEqualTo: true);

    var convsersationsStream = ref.snapshots();

    var profilesStream = getContacs().asStream();

    return Rx.combineLatest2(
      convsersationsStream,
      profilesStream,
      (QuerySnapshot conversations, List<Profile> profiles) =>
          conversations.docs.map(
        (snapshot) {
          List<String> members = List.from(snapshot['members']);

          var profile = profiles.firstWhere(
            (element) =>
                element.id == members.firstWhere((member) => member != userId),
          );
          return Conversation.fromSnapshot(snapshot, 0, profile: profile);
        },
      ).toList(),
    );
  }

  Future<List<Profile>> getContacs() async {
    var data = await FirebaseFirestore.instance
        .doc("users/${firebaseAuth.currentUser.uid}")
        .get();

    var ref = _firestore
        .collection("users")
        .where("phoneNumber", isNotEqualTo: data.data()['phoneNumber']);

    var documents = await ref.get();
    return documents.docs
        .map((snapshot) => Profile.fromSnapshot(snapshot))
        .toList();
  }

  Future<List<Profile>> getContacsQuery(String username) async {
    var data = await FirebaseFirestore.instance
        .doc("users/${firebaseAuth.currentUser.uid}")
        .get();

    var ref = _firestore
        .collection("users")
        .where("phoneNumber", isNotEqualTo: data.data()['phoneNumber'])
        .where("username", isGreaterThanOrEqualTo: username);

    var documents = await ref.get();

    return documents.docs
        .map((snapshot) => Profile.fromSnapshot(snapshot))
        .toList();
  }

  getConverstation(String convID, String userID) async {
    var profileSnapshot =
        await _firestore.collection("users").doc(userID).get();
    var profile = Profile.fromSnapshot(profileSnapshot);
    return Conversation(
        id: convID,
        profileImage: profile.image,
        name: profile.userName,
        displayMessage: "",
        unreadedMessages: 0,
        displayMessageDate: "");
  }

  Future<Conversation> startConversation(
      User user, Profile profile, BuildContext context, String type) async {
    DateFormat dateFormat = DateFormat('HH:mm a');
    String randomStr = randomAlphaNumeric(30);
    var ref = _firestore.collection('conversations');
    Map<String, dynamic> data = {
      'displayMessage': 'Yeni bir sohbet başlatıldı',
      'displayMessageDate': dateFormat.format(DateTime.now())
    };

    var displayMessageData =
        EncodingDecodingService.encodeAndEncrypt(data, randomStr, randomStr);

    await ref.doc(randomStr).set({
      'displayMessageData': displayMessageData,
      'unreadedMessages': 0,
      'type': type,
      'id': randomStr,
      'members': [user.uid, profile.id],
      'closed_friends_${user.uid}': false,
      'closed_friends_${profile.id}': false,
      'notificationStatus_${user.uid}': true,
      'notificationStatus_${profile.id}': true,
      'archived_${user.uid}': false,
      'archived_${profile.id}': false,
    });

    Conversation conv = Conversation(
      id: randomStr,
      displayMessage: 'Yeni bir sohbet başlatıldı',
      displayMessageDate: dateFormat.format(DateTime.now()),
      closedFriends: false,
      name: profile.userName,
      profileImage: profile.image,
    );
    Profile userprofile = await profileService.getProfileInfo(user.uid);
    await sendSystemMessage(conv.id,
        "${userprofile.userName} kişisi, ${profile.userName} kişisiyle yeni bir sohbet başlattı");
    return conv;
  }

  Future sendSystemMessage(String convId, String message) async {
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

  Future addGroupMembers(
      List<Profile> profileList, Conversation groupConversation) async {
    List userList = groupConversation.userList;
    profileList.forEach((element) {
      if (!userList.contains(element.id)) {
        userList.add(element.id);
      }
    });
    List<Map<String, dynamic>> notificationStatuses = [];
    List<Map<String, dynamic>> archivedStatuses = [];
    userList.forEach((element) {
      notificationStatuses.add({
        "notificationStatus_$element": true,
      });
    });
    userList.forEach((element) {
      archivedStatuses.add({
        "archived_$element": false,
      });
    });
    Map<String, dynamic> datas = {"members": userList};
    notificationStatuses.forEach((element) {
      datas.addAll(element);
    });

    archivedStatuses.forEach((element) {
      datas.addAll(element);
    });

    await FirebaseFirestore.instance
        .doc("conversations/${groupConversation.id}")
        .update(datas);

    profileList.forEach((element) async {
      await sendSystemMessage(
          groupConversation.id, "${element.userName} kişisi bu gruba katıldı");
    });
  }

  Future blockGroupMembers(
      String userId, Conversation groupConversation) async {
    List members = groupConversation.userList;
    members.remove(userId);
    Profile myProfile =
        await profileService.getProfileInfo(firebaseAuth.currentUser.uid);
    Profile profile = await profileService.getProfileInfo(userId);
    await sendSystemMessage(groupConversation.id,
        "${myProfile.userName} kişisi, ${profile.userName} adlı kişiyi bu gruptan çıkardı");
    await FirebaseFirestore.instance
        .doc("conversations/${groupConversation.id}")
        .update({"members": members});
  }

  Future<Conversation> startNewGroup(List<String> members, BuildContext context,
      String type, String groupName, String profileImage) async {
    DateFormat dateFormat = DateFormat('HH:mm a');
    String randomStr = randomAlphaNumeric(30);
    String image = profileImage ??
        "https://st.depositphotos.com/1779253/5140/v/600/depositphotos_51405259-stock-illustration-male-avatar-profile-picture-use.jpg";
    var ref = _firestore.collection('conversations');
    Map<String, dynamic> data = {
      'displayMessage': 'Yeni bir grup başlatıldı',
      'displayMessageDate': dateFormat.format(DateTime.now())
    };

    List<Map<String, dynamic>> notificationStatuses = [];
    List<Map<String, dynamic>> archivedStatuses = [];
    List<Map<String, dynamic>> closedFriends = [];

    members.forEach((element) {
      notificationStatuses.add({
        "notificationStatus_$element": true,
      });
    });
    members.forEach((element) {
      closedFriends.add({
        "closed_friends_$element": false,
      });
    });
    members.forEach((element) {
      archivedStatuses.add({
        "archived_$element": false,
      });
    });
    var displayMessageData = EncodingDecodingService.encodeAndEncrypt(
        data, randomStr, firebaseAuth.currentUser.uid);
    Map<String, dynamic> datas = {
      'displayMessageData': displayMessageData,
      'unreadedMessages': 0,
      'type': type,
      'id': randomStr,
      'groupName': groupName,
      'groupOwner': firebaseAuth.currentUser.uid,
      'profileImage': image,
      'members': members,
    };
    notificationStatuses.forEach((element) {
      datas.addAll(element);
    });
    archivedStatuses.forEach((element) {
      datas.addAll(element);
    });
    closedFriends.forEach((element) {
      datas.addAll(element);
    });
    await ref.doc(randomStr).set(datas);
    Conversation conv = Conversation(
      id: randomStr,
      archived: false,
      groupOwner: firebaseAuth.currentUser.uid,
      userList: members,
      closedFriends: false,
      unreadedMessages: 0,
      displayMessage: 'Yeni bir grup başlatıldı',
      displayMessageDate: dateFormat.format(DateTime.now()),
      name: groupName,
      profileImage: image,
    );

    Profile userprofile =
        await profileService.getProfileInfo(firebaseAuth.currentUser.uid);
    await sendSystemMessage(conv.id,
        "${userprofile.userName} kişisi $groupName isimli bir grup kurdu");

    members.forEach((element) async {
      Profile profile = await profileService.getProfileInfo(element);
      await sendSystemMessage(
          conv.id, "${profile.userName} kişisi bu gruba katıldı");
    });

    return conv;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sohbetapp/core/services/encoding_decoding.dart';
import 'package:sohbetapp/models/conversation_type.dart';
import 'package:sohbetapp/models/profile.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';

class Conversation {
  String id;
  String name;
  String profileImage;
  String displayMessage;
  bool archived;
  String displayMessageDate;
  String groupOwner;
  bool notificationState;
  bool closedFriends;
  String beatifunID;
  String browserURL;
  String videoID;
  List userList;
  int unreadedMessages;
  ConversationType conversationType;

  Conversation(
      {this.id,
      this.name,
      this.profileImage,
      this.userList,
      this.beatifunID,
      this.unreadedMessages,
      this.browserURL,
      this.videoID,
      this.displayMessage,
      this.displayMessageDate,
      this.notificationState,
      this.archived,
      this.closedFriends,
      this.groupOwner,
      this.conversationType});

  factory Conversation.fromSnapshot(
      DocumentSnapshot snapshot, int unreadedmessageData,
      {Profile profile}) {
    String convType = snapshot.data()['type'];

    Map<String, dynamic> data =
        convType == "normal_chat" || convType == "private_chat"
            ? EncodingDecodingService.decryptAndDecode(
                snapshot.data()['displayMessageData'],
                snapshot.data()['id'],
                snapshot.data()['id'])
            : EncodingDecodingService.decryptAndDecode(
                snapshot.data()['displayMessageData'],
                snapshot.data()['id'],
                snapshot.data()['groupOwner']);

    return Conversation(
        beatifunID: snapshot.data()['beatifunID'] == null
            ? "NON-ID"
            : snapshot.data()['beatifunID'],
        browserURL: snapshot.data()['browserURL'] == null
            ? "NON-ID"
            : snapshot.data()['browserURL'],
        videoID: snapshot.data()['videoID'] == null
            ? "NON-ID"
            : snapshot.data()['videoID'],
        groupOwner: snapshot.data()['groupOwner'] ?? "",
        id: snapshot.id,
        name: convType == 'group_chat' || convType == 'private_group'
            ? snapshot.data()['groupName']
            : profile.userName,
        profileImage: convType == 'group_chat' || convType == 'private_group'
            ? snapshot.data()['profileImage']
            : profile.image,
        displayMessage: convType == "private_chat" ||
                convType == "private_group"
            ? "Bu bir gizli sohbettir mesajları görebilmek için şifreyi giriniz"
            : data['displayMessage'],
        userList: snapshot.data()['members'],
        displayMessageDate: data['displayMessageDate'],
        archived: snapshot.data()['archived_${firebaseAuth.currentUser.uid}'],
        closedFriends:
            snapshot.data()['closed_friends_${firebaseAuth.currentUser.uid}'],
        unreadedMessages: unreadedmessageData,
        notificationState: snapshot
            .data()['notificationStatus_${firebaseAuth.currentUser.uid}'],
        conversationType: convType == "normal_chat"
            ? ConversationType.normal_chat
            : (convType == "private_chat"
                ? ConversationType.private_chat
                : (convType == "group_chat"
                    ? ConversationType.group_chat
                    : ConversationType.private_group)));
  }
}

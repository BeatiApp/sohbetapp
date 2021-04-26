import 'package:sohbetapp/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  Future<Profile> getProfileInfo(String userId) async {
    var data = await FirebaseFirestore.instance.doc("users/$userId").get();
    Profile profile = Profile.fromSnapshot(data);
    return profile;
  }

  Future blockProfile(String myId, String userId) async {
    var data = await FirebaseFirestore.instance.doc("users/$myId").get();
    var userData = data.data();
    List blockedUsers = userData['blockedUsers'] ?? [];
    blockedUsers.add(userId);

    await FirebaseFirestore.instance
        .doc("users/$myId")
        .update({"blockedUsers": blockedUsers});

    var convData1 = await FirebaseFirestore.instance
        .collection("conversations")
        .where("members", isEqualTo: [myId, userId]).get();

    convData1.docs.forEach((element) async {
      await FirebaseFirestore.instance
          .doc("conversations/${element.id}")
          .delete();
    });

    var convData2 = await FirebaseFirestore.instance
        .collection("conversations")
        .where("members", isEqualTo: [userId, myId]).get();
    convData2.docs.forEach((element) async {
      await FirebaseFirestore.instance
          .doc("conversations/${element.id}")
          .delete();
    });
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/core/services/profileService.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:sohbetapp/models/profile.dart';
import 'package:sohbetapp/models/profile_story.model.dart';
import 'package:sohbetapp/models/story_model.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/viewmodels/contacts_model.dart';

class StoryService {
  final StorageService storageService = getIt<StorageService>();
  final ProfileService profileService = getIt<ProfileService>();
  final ContactsModel contactsModel = getIt<ContactsModel>();

  Future<String> _uploadImageList(File file) async {
    List<String> urlList = [];

    Map<String, dynamic> map = await storageService.uploadMedia(file);

    urlList.add(map['url']);

    return urlList.first;
  }

  createNewStory(File image, String description) async {
    String fileImage = await _uploadImageList(image);
    Profile profile =
        await profileService.getProfileInfo(firebaseAuth.currentUser.uid);

    await FirebaseFirestore.instance
        .collection("users/${profile.id}/stories")
        .add({
      "profileID": profile.id,
      "profileName": profile.userName,
      "dateTime": DateTime.now(),
      "image": fileImage,
      "description": description,
    });
  }

  Future<List<StoryModel>> getStoriesByUserId(String userID) async {
    List<StoryModel> stories = [];
    var data = await FirebaseFirestore.instance
        .collection("users/$userID/stories")
        .get();
    data.docs.forEach((element) {
      StoryModel model = StoryModel.fromSnapshot(element);
      stories.add(model);
    });
    return stories;
  }

  Future<bool> checkStoryState(String userID) async {
    var data = await FirebaseFirestore.instance
        .collection("users/$userID/stories")
        .get();

    return data.docs.isNotEmpty;
  }

  Future deleteStories() async {
    var data = await FirebaseFirestore.instance
        .collection("users/${firebaseAuth.currentUser.uid}/stories")
        .get();
    data.docs.forEach((element) async {
      await FirebaseFirestore.instance
          .doc("users/${firebaseAuth.currentUser.uid}/stories/${element.id}")
          .delete();
    });
  }

  Future<List<ProfileAndStoryModel>> getContactsAndStories() async {
    List<Profile> contactList = await contactsModel.getContacts();
    List<ProfileAndStoryModel> storiesData = [];

    await Future.forEach(contactList, (element) async {
      List<StoryModel> stories = await getStoriesByUserId(element.id);
      ProfileAndStoryModel data = ProfileAndStoryModel(element, stories);
      storiesData.add(data);
    });
    return storiesData;
  }
}

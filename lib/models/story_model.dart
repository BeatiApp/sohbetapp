import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StoryModel {
  final String profileID;
  final String profileName;
  final String dateTime;
  final String image;
  final String description;

  StoryModel(this.profileID, this.profileName, this.dateTime, this.image,
      this.description);

  factory StoryModel.fromSnapshot(QueryDocumentSnapshot snapshot) {
    DateFormat dateFormat = DateFormat("HH:mm");
    return StoryModel(
        snapshot.data()['profileID'],
        snapshot.data()['profileName'],
        dateFormat.format(snapshot.data()['dateTime'].toDate()),
        snapshot.data()['image'],
        snapshot.data()['description']);
  }
}

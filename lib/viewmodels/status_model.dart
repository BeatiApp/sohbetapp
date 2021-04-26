import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sohbetapp/viewmodels/base_model.dart';

class StatusModel extends BaseModel {
  final List<String> imageURL;
  final List<String> description;
  final String senderID;
  final String senderPhoneNumber;
  final String senderName;
  final String sendingDate;

  StatusModel(
      {this.imageURL,
      this.description,
      this.senderID,
      this.senderPhoneNumber,
      this.senderName,
      this.sendingDate});

  factory StatusModel.fromSnapshot(DocumentSnapshot snapshot) {
    Timestamp timestamp = snapshot.data()['sendingDate'];
    DateTime dateTime = timestamp.toDate();
    DateFormat format = DateFormat(DateFormat.HOUR24_MINUTE);
    String date = format.format(dateTime);

    return StatusModel(
        imageURL: snapshot.data()['imageURL'],
        description: snapshot.data()['description'],
        senderID: snapshot.data()['senderID'],
        senderPhoneNumber: snapshot.data()['senderPhoneNumber'],
        senderName: snapshot.data()['senderName'],
        sendingDate: date);
  }
}

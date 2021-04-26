import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Profile {
  String id;
  String userName;
  String image;
  String phoneNumber;
  String email;
  String lastSeenHour;
  String token;
  String status;
  List usernameQuery;

  Profile(
      {this.id,
      this.userName,
      this.image,
      this.email,
      this.token,
      this.status,
      this.lastSeenHour,
      this.phoneNumber,
      this.usernameQuery});

  factory Profile.fromSnapshot(DocumentSnapshot snapshot) {
    DateFormat hourDateFormat = DateFormat("dd/MM/yyyy hh:mm");
    return Profile(
        id: snapshot.id,
        status:
            snapshot.data()['status'] ?? "Merhaba, ben Sohbet kullanıyorum!",
        email: snapshot.data()['email'],
        userName: snapshot.data()["username"],
        usernameQuery: snapshot.data()['usernameQuery'],
        token: snapshot.data()['token'],
        image: snapshot.data()["profileImage"],
        lastSeenHour:
            hourDateFormat.format(snapshot.data()['lastSeenHour'].toDate()),
        phoneNumber:
            snapshot.data()['phoneNumber'] ?? "Telefon Numarası Kayıtlı Değil");
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sohbetapp/core/services/encoding_decoding.dart';

class SearchMessageWidget extends StatelessWidget {
  final QueryDocumentSnapshot snapshot;

  const SearchMessageWidget({Key key, this.snapshot}) : super(key: key);

  String timeToString(DateTime date) {
    DateFormat dateFormat = DateFormat("dd MMMM yyyy HH:mm");
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    var chatContents = EncodingDecodingService.decryptAndDecode(
        snapshot.data()['data'],
        snapshot.id,
        snapshot.data()['senderId'] ?? "System");

    return Container(
      child: ListTile(
        title: Text(chatContents['message']),
        subtitle: Row(
          children: [
            Text("Gönderen: ${chatContents['senderName']}"),
            Spacer(),
            Text("Tarih: ${timeToString(chatContents['date'].toDate())}")
          ],
        ),
      ),
    );
  }
}

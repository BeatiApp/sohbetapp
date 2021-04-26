import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'package:sohbetapp/widgets/chats/search_message_widget.dart';

class SearchMessages extends SearchDelegate {
  final Conversation conversation;

  Future<List<QueryDocumentSnapshot>> getMessages(String searchQuery) async {
    var data = await FirebaseFirestore.instance
        .collection("conversations/${conversation.id}/messages")
        .get();
    return data.docs;
  }

  SearchMessages({this.conversation});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      accentColor: Theme.of(context).primaryColor,
      primaryColorBrightness: Brightness.light,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          close(context, () {
            print("SearchBar Closed");
          });
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getMessages(query),
        builder:
            (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) =>
                ListView(
                    children: snapshot.data
                        .map<Widget>((e) => SearchMessageWidget())
                        .toList()),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return null;
  }
}

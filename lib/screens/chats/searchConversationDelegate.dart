import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/screens/chats/empty_conversations.dart';
import 'package:sohbetapp/viewmodels/viewmodels.dart';
import 'package:sohbetapp/widgets/chats/chatTile.dart';

class ConversationSearchDelegate extends SearchDelegate {
  var model = getIt<ChatsModel>();
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);

    return theme.copyWith(
      primaryColor: Theme.of(context).primaryColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    ScrollController listController = ScrollController();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<Conversation>>(
        stream: model.getConversationQuery(firebaseAuth.currentUser.uid, query),
        builder:
            (BuildContext context, AsyncSnapshot<List<Conversation>> snapshot) {
          if (snapshot.hasError) {
            return ChatNotFound();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.separated(
            controller: listController,
            itemBuilder: (context, index) {
              var doc = snapshot.data[index];
              return ChatTile(
                doc: doc,
                user: firebaseAuth.currentUser,
              );
            },
            itemCount: snapshot.data.length,
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 2,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    ScrollController listController = ScrollController();
    return ChangeNotifierProvider(
      create: (BuildContext context) => model,
      child: StreamBuilder<List<Conversation>>(
        stream: model.getConversationQuery(firebaseAuth.currentUser.uid, query),
        builder:
            (BuildContext context, AsyncSnapshot<List<Conversation>> snapshot) {
          if (snapshot.hasError) {
            return ChatNotFound();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.separated(
            controller: listController,
            itemBuilder: (context, index) {
              var doc = snapshot.data[index];
              return ChatTile(
                doc: doc,
                user: firebaseAuth.currentUser,
              );
            },
            itemCount: snapshot.data.length,
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 2,
              );
            },
          );
        },
      ),
    );
  }
}

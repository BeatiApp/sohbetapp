import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/viewmodels/viewmodels.dart';
import 'package:sohbetapp/widgets/chats/chatTile.dart';

class ArchivedConversations extends StatefulWidget {
  @override
  _ArchivedConversationsState createState() => _ArchivedConversationsState();
}

class _ArchivedConversationsState extends State<ArchivedConversations> {
  var model = getIt<ChatsModel>();
  ScrollController listController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Arşivlenmiş Sohbetler"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: ChangeNotifierProvider(
        create: (BuildContext context) => model,
        child: StreamBuilder<List<Conversation>>(
          stream: model.getArchivedConversations(firebaseAuth.currentUser.uid),
          builder: (BuildContext context,
              AsyncSnapshot<List<Conversation>> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/archieve.svg",
                    height: 120,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Arşivlenmiş Sohbet Bulunamadı",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ))
                ],
              ));
            }
            return ListView.separated(
              controller: listController,
              itemBuilder: (context, index) {
                var doc = snapshot.data[index];
                return ChatTile(
                  doc: doc,
                  newMessageBoolean: doc.unreadedMessages > 0,
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
      ),
    );
  }
}

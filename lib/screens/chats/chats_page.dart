import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/chats/archived_conversation.dart';
import 'package:sohbetapp/screens/chats/empty_conversations.dart';
import 'package:sohbetapp/screens/chats/sohbet_notification_system.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/viewmodels/chats_model.dart';
import 'package:sohbetapp/widgets/chats/chatTile.dart';
import 'package:sohbetapp/widgets/chats/chat_action_button.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key key}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  bool showSohbetSystem = true;
  getShowSohbetInfo() async {
    var prefs = await SharedPreferences.getInstance();
    bool data = prefs.getBool("showSohbetSystem");
    if (data != null) {
      setState(() {
        showSohbetSystem = data;
      });
    }
  }

  @override
  void initState() {
    getShowSohbetInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = getIt<ChatsModel>();
    var user = firebaseAuth.currentUser;
    ScrollController listController = ScrollController();
    return Scaffold(
      floatingActionButton: ChatActionButton(),
      body: ChangeNotifierProvider(
        create: (BuildContext context) => model,
        child: StreamBuilder<List<Conversation>>(
          stream: model.conversations(user.uid),
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

            return snapshot.data.length != 0
                ? ListView(
                    controller: listController,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.archive, color: Colors.white),
                          backgroundColor: Colors.grey,
                        ),
                        title: Text("Arşivlenmiş Sohbetler"),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArchivedConversations(),
                              ));
                        },
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      showSohbetSystem == true
                          ? ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/logos/logo.png"),
                                backgroundColor: Colors.white,
                              ),
                              trailing: TextButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool("showSohbetSystem", false);
                                    setState(() {
                                      showSohbetSystem = false;
                                    });
                                  },
                                  child: Text(
                                    "Gizle",
                                    style: GoogleFonts.roboto(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  )),
                              title: Text("Sohbet Sistem"),
                              subtitle: Text(
                                  "Uygulama güncellemelerinden hemen haberdar olun"),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SohbetNotificationSystem(),
                                    ));
                              },
                            )
                          : SizedBox(),
                      showSohbetSystem == true
                          ? Divider(
                              thickness: 1,
                            )
                          : SizedBox(),
                    ]..addAll(snapshot.data.map<Widget>((e) {
                        var doc = e;
                        return Column(
                          children: [
                            ChatTile(
                              doc: doc,
                              user: user,
                            ),
                            Divider(
                              thickness: 1,
                            )
                          ],
                        );
                      })))
                : ChatNotFound();
          },
        ),
      ),
    );
  }
}

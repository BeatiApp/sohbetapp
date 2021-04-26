import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sohbetapp/core/services/services.dart';
import 'package:sohbetapp/models/conversation.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/chats/conversation_page.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/utilities/utilities.dart';

class ChatTile extends StatelessWidget {
  final User user;
  final Conversation doc;
  final bool newMessageBoolean;
  const ChatTile({Key key, this.doc, this.user, this.newMessageBoolean})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      direction: Axis.horizontal,
      actionExtentRatio: 0.25,
      secondaryActions: [
        IconSlideAction(
          color: Theme.of(context).primaryColor,
          icon: doc.archived == false ? Icons.archive : Icons.archive_outlined,
          caption: doc.archived == false ? "Arşivle" : "Arşivden Çıkar",
          onTap: () async {
            if (doc.archived == true) {
              await FirebaseFirestore.instance
                  .doc("conversations/${doc.id}")
                  .update({"archived_${firebaseAuth.currentUser.uid}": false});
            } else {
              await FirebaseFirestore.instance
                  .doc("conversations/${doc.id}")
                  .update({"archived_${firebaseAuth.currentUser.uid}": true});
            }
          },
        ),
        IconSlideAction(
          color: Theme.of(context).accentColor,
          onTap: () async {
            if (doc.notificationState == true) {
              await FirebaseFirestore.instance
                  .doc("conversations/${doc.id}")
                  .update({
                "notificationStatus_${firebaseAuth.currentUser.uid}": false
              });
            } else {
              await FirebaseFirestore.instance
                  .doc("conversations/${doc.id}")
                  .update({
                "notificationStatus_${firebaseAuth.currentUser.uid}": true
              });
            }
          },
          caption:
              doc.notificationState == true ? "Sessize Al" : "Bildirimleri Aç",
          icon: doc.notificationState == true
              ? Icons.notifications_none_outlined
              : Icons.notifications_active_outlined,
        ),
        IconSlideAction(
          color: Theme.of(context).splashColor,
          icon:
              doc.closedFriends == false ? Icons.person_add : Icons.exit_to_app,
          caption: doc.closedFriends == false
              ? "Sık Görüşülenlere\n  Ekle"
              : "Sık Görüşülenlere\n  Çıkar",
          onTap: () async {
            if (doc.closedFriends == true) {
              await FirebaseFirestore.instance
                  .doc("conversations/${doc.id}")
                  .update({
                "closed_friends_${firebaseAuth.currentUser.uid}": false
              });
            } else {
              await FirebaseFirestore.instance
                  .doc("conversations/${doc.id}")
                  .update(
                      {"closed_friends_${firebaseAuth.currentUser.uid}": true});
            }
          },
        ),
      ],
      actionPane: SlidableScrollActionPane(),
      child: ListTile(
        leading: GestureDetector(
          child: CircleAvatar(
            backgroundImage: NetworkImage(doc.profileImage),
          ),
        ),
        title: Text(
          doc.name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        ),
        subtitle: newMessageBoolean == true
            ? Row(
                children: [
                  Icon(
                    Icons.chat_bubble,
                    size: 20,
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Yeni Mesaj Var",
                    style: GoogleFonts.roboto(
                        color: Theme.of(context).accentColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
            : Text(
                doc.displayMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                    color: Theme.of(context).primaryColor, fontSize: 15),
              ),
        trailing: doc.conversationType == ConversationType.normal_chat ||
                doc.conversationType == ConversationType.group_chat
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  doc.unreadedMessages == 0 || doc.unreadedMessages == null
                      ? Container(
                          width: 20,
                          margin: EdgeInsets.only(top: 8),
                          height: 20,
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).iconTheme.color),
                          child: Center(
                            child: Text(
                              doc.unreadedMessages.toString(),
                              textScaleFactor: 0.8,
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(doc.displayMessageDate,
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                      )),
                ],
              )
            : Icon(Icons.lock),
        onTap: () async {
          if (doc.conversationType == ConversationType.private_chat ||
              doc.conversationType == ConversationType.private_group) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String pass = prefs.getString(doc.id);

            if (pass.isNotEmpty) {
              await showDialog(
                context: context,
                builder: (context) {
                  TextEditingController controller = TextEditingController();
                  return AlertDialog(
                    content: Container(
                      height: 150,
                      child: Form(
                        child: Column(
                          children: [
                            Text(
                              "Bu Sohbet gizli bir sohbettir bu sohbete girebilmek için şifre ile giriş yapmanız gerekir!",
                              style: GoogleFonts.roboto(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                hintText: "Gizli Sohbet Şifresi",
                                suffixIcon: Icon(Icons.lock),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      RaisedButton(
                        onPressed: () async {
                          bool passState = EncryptionService.checkMD5EqualTo(
                              pass, controller.text);

                          if (passState == true) {
                            await Navigator.of(context)
                                .pushReplacement(FadePageRoute(
                              page: ConversationPage(
                                userId: user.uid,
                                conversation: doc,
                              ),
                            ));
                          }
                        },
                        child: Text("SOHBETE DEVAM ET"),
                      )
                    ],
                  );
                },
              );
            } else {
              await showDialog(
                context: context,
                builder: (context) {
                  TextEditingController controller = TextEditingController();
                  return AlertDialog(
                    content: Container(
                      height: 150,
                      child: Form(
                        child: Column(
                          children: [
                            Text(
                              "Bu sohbete daha önce hiç katılmadın bunun için aşağıdan hemen bir şifre belirle. Unutma gizli sohbetler normal sohbetlere göre çok daha güvenlidir. Şifre belirlemezsen şifren 12345 olarak atanır",
                              style: GoogleFonts.roboto(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                hintText: "Gizli Sohbet Şifresi",
                                suffixIcon: Icon(Icons.lock),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      RaisedButton(
                        onPressed: () async {
                          String hash = EncryptionService.generateMD5Hash(
                              controller.text ?? "12345");
                          prefs.setString(doc.id, hash);
                          await Navigator.of(context).push(FadePageRoute(
                            page: ConversationPage(
                              userId: user.uid,
                              conversation: doc,
                            ),
                          ));
                        },
                        child: Text("SOHBETE KATIL"),
                      )
                    ],
                  );
                },
              );
            }
          }
          if (doc.conversationType == ConversationType.group_chat ||
              doc.conversationType == ConversationType.normal_chat)
            await Navigator.of(context).push(FadePageRoute(
              page: ConversationPage(
                userId: user.uid,
                conversation: doc,
              ),
            ));
        },
      ),
    );
  }
}

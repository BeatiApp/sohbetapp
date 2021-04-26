import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sohbetapp/models/conversation_type.dart';
import 'package:sohbetapp/screens/contacts/contacts_group_page.dart';
import 'package:sohbetapp/screens/contacts/contacts_page.dart';
import 'package:sohbetapp/utilities/right_page_route.dart';

class ChatActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      marginBottom: 90,
      animatedIcon: AnimatedIcons.menu_arrow,
      tooltip: "Yeni Sohbet Oluştur",
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
            child: Icon(Icons.chat),
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Yeni Sohbet Oluştur',
            labelStyle: GoogleFonts.roboto(fontSize: 18.0),
            onTap: () {
              Navigator.of(context).push(SlideRightRoute(
                  page: ContactsPage(
                conversationType: ConversationType.normal_chat,
              )));
            }),
        SpeedDialChild(
          child: Icon(FontAwesomeIcons.userLock),
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Yeni Gizli Sohbet Oluştur',
          labelStyle: GoogleFonts.roboto(fontSize: 18.0),
          onTap: () {
            Navigator.of(context).push(SlideRightRoute(
                page: ContactsPage(
              conversationType: ConversationType.private_chat,
            )));
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.people),
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Yeni Grup Oluştur',
          labelStyle: GoogleFonts.roboto(fontSize: 18.0),
          onTap: () {
            Navigator.of(context).push(SlideRightRoute(
                page: ContactsGroupPage(
              conversationType: ConversationType.group_chat,
            )));
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.lock),
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Yeni Gizli Grup Oluştur',
          labelStyle: GoogleFonts.roboto(fontSize: 18.0),
          onTap: () {
            Navigator.of(context).push(SlideRightRoute(
                page: ContactsGroupPage(
              conversationType: ConversationType.private_group,
            )));
          },
        ),
      ],
    );
  }
}

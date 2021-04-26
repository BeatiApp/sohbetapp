import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sohbetapp/models/models.dart';
import 'package:sohbetapp/screens/contacts/contacts_page.dart';

class ChatNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: SvgPicture.asset("assets/svg/chat_not_found.svg"),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Hiçbir Mesaj Bulunamadı",
              style:
                  GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ContactsPage(
                          conversationType: ConversationType.normal_chat,
                        );
                      },
                    ));
                  },
                  icon: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Yeni Sohbet Oluştur",
                    style: GoogleFonts.roboto(color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

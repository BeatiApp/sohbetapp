import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class BeatifunPlayerService {
  YoutubeExplode yt = YoutubeExplode();
  AudioPlayer audioPlayer = AudioPlayer();
  String url;
  closeMusic(String conversationID) async {
    var ref = FirebaseFirestore.instance.collection("conversations");
    ref.doc(conversationID).update({
      "beatifun": {"state": false}
    });
  }

  playMusic() async {}

  initMusic(String musicID, BuildContext context, String conversationID) async {
    TextEditingController controller = TextEditingController();
    var ref = FirebaseFirestore.instance.collection("conversations");

    ref.doc(conversationID).snapshots().listen((event) async {
      if (event.data()['beatifun']['state'] == true) {
        print("Beatifun Player Active");
        url = event.data()['beatifun'][''];
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Beatifun Müzik ID giriniz"),
              content: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () async {
                          bool isInstalled = await DeviceApps.isAppInstalled(
                              "com.beatiapp2.beatifun");

                          if (isInstalled == true) {
                            DeviceApps.openApp("com.beatiapp2.beatifun");
                          } else {
                            launch(
                                "https://play.google.com/store/apps/details?id=com.beatiapp2.beatifun");
                          }
                        },
                        child: Text(
                          "Beatifun'ı başlat",
                          style: GoogleFonts.roboto(
                              decoration: TextDecoration.underline,
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          hintText: "Müzik ID",
                          suffixIcon: Icon(Icons.music_note)),
                    ),
                  ],
                ),
              ),
              actions: [
                RaisedButton(
                  color: Colors.white,
                  onPressed: () async {
                    if (controller.text.isEmpty) {
                      Navigator.pop(context);
                    } else {
                      Video video =
                          await yt.videos.get(controller.text).catchError((e) {
                        debugPrint(e);
                      });
                      var id = VideoId(video.id.value);
                      var explode = YoutubeExplode();
                      var manifest =
                          await explode.videos.streamsClient.getManifest(id);
                      FirebaseFirestore.instance
                          .doc("conversations($conversationID")
                          .update({
                        "beatifun": {
                          "state": true,
                          "position": 0,
                          "playerState": true,
                          "url": manifest.audio.first.url.path,
                        }
                      });
                    }
                  },
                  child: Text("Müziği Başlat"),
                )
              ],
            );
          },
        );
      }
    });
  }
}

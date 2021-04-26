import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sohbetapp/core/locator.dart';
import 'package:sohbetapp/screens/auth/sign_in_page.dart';
import 'package:sohbetapp/screens/sohbet_main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_map_location_picker/generated/l10n.dart'
    as location_picker;
import 'package:sohbetapp/screens/splash_screen.dart';
import 'package:sohbetapp/utilities/sensitive_constants.dart';
import 'package:theme_provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Permission.contacts.isDenied.then((value) async {
    if (value == false) {
      await Permission.contacts.request();
    }
  });

  await Permission.storage.isDenied.then((value) async {
    if (value == false) {
      await Permission.storage.request();
    }
  });

  if (await Directory(storagePath).exists() == false) {
    await Directory(storagePath).create();
  }
  setupLocators();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      defaultThemeId: "dark_theme",
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      themes: [
        AppTheme(
            data: ThemeData(
                primaryColor: Colors.redAccent[400],
                accentColor: Colors.redAccent[200],
                splashColor: Colors.orangeAccent[200],
                iconTheme: IconThemeData(color: Color(0xfff4f9f9))),
            id: 'red_theme',
            description: "Kızıl Tema"),
        AppTheme(
            data: ThemeData(
                primaryColor: Color(0xff19456b),
                accentColor: Color(0xff11698e),
                splashColor: Color(0xff16c79a),
                iconTheme: IconThemeData(color: Colors.greenAccent)),
            id: 'blue_theme',
            description: "Mavi Tema"),
        AppTheme(
            data: ThemeData(
                primaryColor: Color(0xffcc7351),
                accentColor: Color(0xffe08f62),
                splashColor: Color(0xffded7b1),
                iconTheme: IconThemeData(color: Colors.amber)),
            id: 'orange_theme',
            description: "Turuncu Tema"),
        AppTheme(
            data: ThemeData(
                primaryColor: Color(0xfffcf876),
                accentColor: Color(0xffcee397),
                splashColor: Color(0xff8bcdcd),
                iconTheme: IconThemeData(color: Color(0xff3797a4))),
            id: 'yaz_temasi',
            description: "Yaz Teması"),
        AppTheme(
            data: ThemeData(
                primaryColor: Color(0xff822659),
                accentColor: Color(0xffb34180),
                splashColor: Color(0xffe36bae),
                iconTheme: IconThemeData(color: Color(0xfff4f9f9))),
            id: 'purple_theme',
            description: "Pembe Tema"),
        AppTheme(
            data: ThemeData(
                primaryColor: Color(0xff845ec2),
                accentColor: Color(0xffffc75f),
                splashColor: Color(0xffff5e78),
                iconTheme: IconThemeData(color: Color(0xfff9f871))),
            id: 'purple_yellow_theme',
            description: "Mor - Sarı Tema"),
        AppTheme(
            data: ThemeData(
                primaryColor: Colors.black,
                accentColor: Colors.black45,
                splashColor: Color(0xff64dfdf),
                textTheme: TextTheme(
                  bodyText1: TextStyle(color: Colors.black),
                ),
                brightness: Brightness.dark,
                iconTheme: IconThemeData(color: Color(0xff64dfdf))),
            id: 'dark_theme',
            description: "Karanlık Tema"),
      ],
      child: ThemeConsumer(
        child: Builder(builder: (context) {
          return MaterialApp(
            theme: ThemeProvider.themeOf(context).data,
            localizationsDelegates: const [
              location_picker.S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const <Locale>[
              Locale('tr', 'TR'),
            ],
            debugShowCheckedModeBanner: false,
            title: 'Sohbet - Gizli Mesajlaşma',
            home: SplashScreen(
              home: firebaseAuth.currentUser != null
                  ? SohbetMain()
                  : SignInPage(),
              child: Image.asset(
                "assets/icon/icon.png",
                width: 250,
                height: 250,
              ),
            ),
          );
          /**/
        }),
      ),
    );
  }
}

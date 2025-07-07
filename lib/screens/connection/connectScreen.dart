import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showmaker/common/messages.dart';
import 'package:showmaker/design/appThemes.dart';
import 'package:showmaker/design/customButton.dart';
import 'package:showmaker/design/themeColors.dart';

import '../../database/User/dbMethods.dart';
import '../../database/User/user.dart';
import '../../database/connection/authentication.dart';
import '../main_screen/mainScreen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Authentication authentication = Authentication();
  bool googlePressed = false;

  bool loading = false;
  AppState appState = AppState.CheckingConnection;

  @override
  void initState() {
    checkConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: blackColor,
        body: SafeArea(child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          constraints.maxHeight;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [themeColors.lightBlack, themeColors.darkBlack],
                  transform: GradientRotation(pi / 4)),
            ),
            child: Container(
              color: Colors.black.withOpacity(0),
              child: Center(
                  child: Column(children: [
                //Spacer(),
                Text(
                  "Welcome",
                  style: TextStyle(fontSize: 50, color: textColor),
                ),
                Spacer(
                  flex: 3,
                ),
                //

                if (appState == AppState.CheckingConnection ||
                    appState == AppState.Initializing)
                  CircularProgressIndicator(
                    color: themeColors.yellowOrange,
                  ),

                if (appState != AppState.Ready)
                  SizedBox(
                    height: 10,
                  ),

                if (appState != AppState.Ready)
                  Text(
                    appState == AppState.CheckingConnection
                        ? 'Checking connection'
                        : appState == AppState.NoConnection
                            ? 'No connection'
                            : appState == AppState.InvalidKeys
                                ? 'Invalid keys'
                                : 'Initializing app',
                    style: TextStyle(fontSize: 25),
                  ),

                if (appState == AppState.NoConnection)
                  SizedBox(
                    height: 20,
                  ),

                if (appState == AppState.NoConnection)
                  CustomButton(
                    widget: Text(
                      'Try again!',
                      style: TextStyle(fontSize: 25),
                    ),
                    width: 150,
                    height: 60,
                    borderRadius: BorderRadius.circular(10),
                    activated: true,
                    borderColors: [themeColors.yellowOrange],
                    borderWidth: 2,
                    onPressed: () => checkConnection(),
                  ),

                if (appState == AppState.Ready)
                  CustomButton(
                    widget: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset(
                          'assets/svgs/googleIcon.svg',
                          height: 35,
                        ),
                        Spacer(),
                        Text(
                          "Google authentication",
                          style: TextStyle(
                              fontSize: 18,
                              color: baseTheme.textTheme.bodyLarge!.color,
                              fontWeight: FontWeight.w400),
                        ),
                        Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                    width: 300,
                    height: 60,
                    borderRadius: BorderRadius.circular(10),
                    activated: true,
                    borderColors: [
                      themeColors.lightOrange.withOpacity(0.8),
                      themeColors.darkOrange.withOpacity(0.8)
                    ],
                    borderWidth: 2,
                    onPressed: () => googleAction(),
                  ),

                Spacer(),
              ])),
            ),
          );
        })));
  }

  void checkConnection() async {
    appState = AppState.CheckingConnection;
    setState(() {});
    final result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      initBackend();
    } else {
      appState = AppState.NoConnection;
      setState(() {});
    }
  }

  void initBackend() async {
    appState = AppState.Initializing;
    setState(() {});
    await dotenv.load();
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: dotenv.env["FIRE_apiKey"]!,
            authDomain: dotenv.env["FIRE_authDomain"]!,
            projectId: dotenv.env["FIRE_projectId"]!,
            storageBucket: dotenv.env["FIRE_storageBucket"]!,
            messagingSenderId: dotenv.env["FIRE_messagingSenderId"]!,
            appId: dotenv.env["FIRE_appId"]!,
            measurementId: dotenv.env["FIRE_measurementId"]!),
      );
      OpenAI.apiKey = dotenv.env['OPEN_AI_API_KEY']!;
      appState = AppState.Ready;
    } catch (e) {
      appState = AppState.InvalidKeys;
    }
    setState(() {});
  }

  void googleAction() async {
    if (googlePressed) return;
    googlePressed = true;

    User? user = await authentication.signInWithGoogle(context: context);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
            content: 'Error signing in. Try again.',
            textColor: Colors.redAccent),
      );
      googlePressed = false;
      return;
    }

    User1? user1 = await getUser(user.uid);
    if (user1 == null) {
      user1 = await createUser(user);
      if (user1 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
              content: 'Error signing in. Try again.',
              textColor: Colors.redAccent),
        );
        googlePressed = false;
      }
    }
    if (user1 != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
            content: 'Successfully signed in.', textColor: Colors.greenAccent),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/MainScreen"),
          builder: (context) => MainScreen(user1: user1!),
        ),
      );
    }
  }
}

enum AppState {
  CheckingConnection,
  NoConnection,
  Initializing,
  Ready,
  InvalidKeys
}

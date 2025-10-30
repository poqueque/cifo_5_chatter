import 'package:chatter/screens/chat_home.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String status = "Inicialitzant...";

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, init);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 100),
            Text('Chatter', style: AppStyles.title),
            AppStyles.separator,
            Text(status),
          ],
        ),
      ),
    );
  }

  void init() {
    User? user = FirebaseAuth.instance.currentUser;
    final providers = [EmailAuthProvider()];

    if (user == null) {
      debugPrint("Usuari no loginat");
      //Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<UserCreated>((context, state) {
                // Put any new user logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHome()),
                );
              }),
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHome()),
                );
              }),
            ],
          ),
        ),
      );
    } else {
      debugPrint("Usuari loginat: ${user.uid}");
      //Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatHome()),
      );
    }
  }
}

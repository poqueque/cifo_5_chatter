import 'package:chatter/firebase_options.dart';
import 'package:chatter/screens/splash.dart';
import 'package:chatter/services/message_provider.dart';
import 'package:chatter/styles/app_styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageReceived);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessageProvider(),
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppStyles.ashGrey,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
        home: Splash(),
        supportedLocales: const [Locale('es'), Locale('ca')],
        localizationsDelegates: [
          FirebaseUILocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageReceived(RemoteMessage message) async {
  Firebase.initializeApp();
  debugPrint(
    "Rebut missatge en background: ${message.notification?.body ?? "No data"}",
  );
}

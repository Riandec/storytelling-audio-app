import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:storytelling_audio_app/api/firebase_message_api.dart';
import 'package:storytelling_audio_app/screens/home_page.dart';
import 'package:storytelling_audio_app/core/theme_provider.dart';
import 'firebase_options_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessageApi().initNotifications();
  await FirebaseMessaging.instance.subscribeToTopic('new_stories');
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Storytelling Audio App',
          theme: themeProvider.currentTheme,
          debugShowCheckedModeBanner: true,
          home: HomePage(),
        );
      },
    );
  }
}

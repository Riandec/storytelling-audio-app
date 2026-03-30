import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytelling_audio_app/api/firebase_message_api.dart';
import 'package:storytelling_audio_app/core/theme_provider.dart';
import 'package:storytelling_audio_app/screens/about_page.dart';
import 'package:storytelling_audio_app/screens/faq_page.dart';
import 'package:storytelling_audio_app/screens/privacy_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final searchController = SearchController();
  bool notiEnabled = false;
  bool darkModeEnabled = false;
  final firebaseMessageApi = FirebaseMessageApi();

  @override
  void initState() {
    super.initState();
    loadNotification();
  }

  Future<void> loadNotification() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notiEnabled = prefs.getBool('notiEnabled') ?? false;
    });
  }

  Future<void> updateNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == true) {
      bool allow = await firebaseMessageApi.enableNotifications();
      if (allow) {
        setState(() {
          notiEnabled = true;
        });
        await prefs.setBool('notiEnabled', true);
      } else {
        setState(() {
          notiEnabled = false;
        });
        await prefs.setBool('notiEnabled', false);
      }
    } else {
      await firebaseMessageApi.disableNotifications();
      setState(() {
        notiEnabled = false;
      });
      await prefs.setBool('notiEnabled', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkTheme = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkTheme 
              ? [
                Color.fromRGBO(0, 68, 114, 1),
                Colors.black,
                Color.fromRGBO(49, 33, 70, 1),
              ]
              : [
                Color.fromRGBO(180, 225, 255, 1),
                Color.fromRGBO(243, 255, 181, 1),
                Colors.white,
              ]
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 70, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 25),
              ListTile(
                leading: Icon(Icons.notifications_none_rounded),
                title: Text(
                  'Notification',
                  style: TextStyle(
                    letterSpacing: 1
                  ),
                ),
                trailing: Switch(
                  value: notiEnabled, 
                  onChanged: updateNotification
                ),
                minTileHeight: 40,
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.dark_mode_outlined),
                title: Text(
                  'Dark mode',
                  style: TextStyle(
                    letterSpacing: 1
                  ),
                ),
                trailing: Switch(
                  value: themeProvider.isDark, 
                  onChanged: (value){
                    setState(() {
                      darkModeEnabled = value;
                    });
                    themeProvider.toggleTheme(value);
                  },
                ),
                minTileHeight: 40,
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPage()
                    )
                  );
                },
                leading: Icon(Icons.lock_outline_rounded),
                title: Text(
                  'Privacy and Security',
                  style: TextStyle(
                    letterSpacing: 1
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 22),
                minTileHeight: 40,
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FAQPage()
                    )
                  );
                },
                leading: Icon(Icons.textsms_outlined),
                title: Text(
                  'Help and FAQ',
                  style: TextStyle(
                    letterSpacing: 1
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 22),
                minTileHeight: 40,
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage()
                    )
                  );
                },
                leading: Icon(Icons.info_outline),
                title: Text(
                  'About Us',
                  style: TextStyle(
                    letterSpacing: 1
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 22),
                minTileHeight: 40,
              ),
              Divider(),
            ],
          )
        )
      ),
    );
  }
}

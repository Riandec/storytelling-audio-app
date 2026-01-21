import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(180, 225, 255, 1),
              Color.fromRGBO(243, 255, 181, 1),
              Colors.white,
            ]
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // search bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    hintText: 'Enter the name of the story...',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB3B3B3)
                    ),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                          } 
                        ) 
                      : null,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Color(0xFFB3B3B3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.black)
                    )
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.notifications_none_rounded, color: Colors.black),
                  title: Text(
                    'Notification',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Switch(
                    value: notiEnabled, 
                    onChanged: (value){
                      setState(() {
                        notiEnabled = value;
                      });
                    },
                    inactiveThumbColor: Colors.white,
                    activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                    inactiveTrackColor: Color.fromARGB(255, 213, 208, 214),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return Colors.transparent;
                    }),
                  ),
                  minTileHeight: 40,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined, color: Colors.black),
                  title: Text(
                    'Dark mode',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Switch(
                    value: darkModeEnabled, 
                    onChanged: (value){
                      setState(() {
                        darkModeEnabled = value;
                      });
                    },
                    inactiveThumbColor: Colors.white,
                    activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                    inactiveTrackColor: Color.fromARGB(255, 213, 208, 214),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.transparent;
                      }
                      return Colors.transparent;
                    }),
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
                  leading: Icon(Icons.lock_outline_rounded, color: Colors.black),
                  title: Text(
                    'Privacy and Security',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
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
                  leading: Icon(Icons.textsms_outlined, color: Colors.black),
                  title: Text(
                    'Help and FAQ',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
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
                  leading: Icon(Icons.info_outline, color: Colors.black),
                  title: Text(
                    'About Us',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
                  minTileHeight: 40,
                ),
                Divider(),
              ],
            )
          ),
        )
      ),
    );
  }
}

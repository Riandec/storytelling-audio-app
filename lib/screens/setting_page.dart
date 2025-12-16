import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final searchController = SearchController();

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
                  leading: Icon(Icons.person_outline_rounded, color: Colors.black),
                  title: Text(
                    'Profile',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
                  minTileHeight: 40,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications_none_rounded, color: Colors.black),
                  title: Text(
                    'Notification',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
                  minTileHeight: 40,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.remove_red_eye_outlined, color: Colors.black),
                  title: Text(
                    'Appearance',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
                  minTileHeight: 40,
                ),
                Divider(),
                ListTile(
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
                  leading: Icon(Icons.headphones_outlined, color: Colors.black),
                  title: Text(
                    'Help and Support',
                    style: TextStyle(
                      letterSpacing: 1
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 22),
                  minTileHeight: 40,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.question_mark_rounded, color: Colors.black),
                  title: Text(
                    'About',
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
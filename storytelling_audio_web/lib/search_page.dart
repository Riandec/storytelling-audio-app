import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'insert_page.dart';
import 'edit_page.dart';
import 'detail_page.dart';
import 'delete_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText = ""; // keep text which user want to search

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Storytelling Management',
          style: GoogleFonts.shortStack(color: Colors.black, fontSize: 28),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // create icon user for log out
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.black,
              size: 35,
            ),
            // press log out
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  // back to login_page.dart
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            // detail in user icon : Email that use, log out button
            itemBuilder: (BuildContext context) {
              final user = FirebaseAuth.instance.currentUser;
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Signed in as",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        user?.email ?? "Guest", // show Email
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(), // line between Email and log out button
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          // call top bar : Search, Insert, Edit, Delete
          _buildTopMenu(),
          Divider(thickness: 1),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value; // keep value in _searchText
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter the name of the story...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          // show list of storytelling that connect with Firebase
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Stories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
                  return Center(
                    child: Text('Something went wrong: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                if (_searchText.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String title = data['title'] ?? '';
                    return title.toLowerCase().contains(
                      _searchText.toLowerCase(),
                    );
                  }).toList();
                }

                if (docs.isEmpty)
                  return Center(child: Text("No stories found"));

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    String title = data['title'] ?? 'No Name';
                    String imageUrl = data['coverUrl'] ?? '';

                    return _buildStoryCard(title, imageUrl, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // top bar
  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuItem("Search", true, () {}), // active page : search_page.dart
          _menuItem(
            "Insert",
            false,
            () => Navigator.pushReplacement(
              context,
              // change page to insert_page.dart
              MaterialPageRoute(builder: (context) => const InsertPage()),
            ),
          ),
          _menuItem(
            "Edit",
            false,
            () => Navigator.pushReplacement(
              context,
              // change page to edit_page.dart
              MaterialPageRoute(builder: (context) => const EditPage()),
            ),
          ),
          _menuItem(
            "Delete",
            false,
            () => Navigator.pushReplacement(
              context,
              // change page to delete_page.dart
              MaterialPageRoute(builder: (context) => const DeletePage()),
            ),
          ),
        ],
      ),
    );
  }

  // create button
  Widget _menuItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.blue
                  : Colors.black, // active : blue text
              fontSize: 16,
            ),
          ),
          if (isActive) // active : blue line
            Container(
              height: 3,
              width: 50,
              color: Colors.blue,
              margin: EdgeInsets.only(top: 5),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(
    String title,
    String imageUrl,
    Map<String, dynamic> data,
  ) {
    List<dynamic> genresRaw = data['genres'] ?? [];
    List<String> genreList = genresRaw.isEmpty
        ? ["General"]
        : genresRaw.map((e) => e.toString()).toList();

    var rating = data['rating']?.toDouble() ?? 0.0;
    var ratingCount = data['ratingCount'] ?? 0;
    var likeCount = data['likeCount'] ?? 0;
    var timing = data['timing'] ?? 0;

    Widget ratingWidget = Container(
      padding: const EdgeInsets.only(left: 5.0, top: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 16),
          SizedBox(width: 2),
          Text(
            " ${rating.toStringAsFixed(1)} stars",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );

    List<Widget> wrapItems = [];
    wrapItems.addAll(genreList.map((genre) => _tagBadge(genre)).toList());
    wrapItems.add(ratingWidget);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(data: data)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Icon(Icons.image, size: 40, color: Colors.grey),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 5.0),
                        child: Text(
                          "Genre: ",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: wrapItems,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Text(
                        "Details: ",
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      Text(
                        " $timing mins  ",
                        style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                      ),
                      Icon(Icons.menu_book, size: 14, color: Colors.grey),
                      Text(
                        " $ratingCount reads  ",
                        style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                      ),
                      Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                      Text(
                        " $likeCount likes",
                        style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // make genre tag have blue color
  Widget _tagBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
      ),
    );
  }
}

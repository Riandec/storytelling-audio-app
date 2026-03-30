import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'insert_page.dart';
import 'search_page.dart';
import 'edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class DeletePage extends StatefulWidget {
  const DeletePage({super.key});

  @override
  State<DeletePage> createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  String _searchText = ""; // keep text that search

  // connfirm and delete data
  Future<void> _confirmDelete(String docId, String storyName) async {
    // alert user before delete
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text("Confirm Delete"),
            ],
          ),
          content: Text(
            "Are you sure you want to delete '$storyName'?\nThis action cannot be undone.",
          ),
          actions: [
            // cancel button
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // confirm delete button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                await FirebaseFirestore.instance
                    .collection('Stories')
                    .doc(docId)
                    .delete();

                // show delete success
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Deleted '$storyName' successfully"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
        // user and logout
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.black,
              size: 35,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
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
                        user?.email ?? "Guest",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
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
          _buildTopMenu(),
          Divider(thickness: 1),
          Padding(
            // search bar
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: 'Enter the name of the story...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          // show storytelling that want to delete
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Stories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                // filter data by search
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
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    // create card for delete
                    return _buildDeleteCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteCard(String docId, Map<String, dynamic> data) {
    List<dynamic> genresRaw = data['genres'] ?? [];
    List<String> genreList = genresRaw.isEmpty
        ? ["General"]
        : genresRaw.map((e) => e.toString()).toList();

    var rating = data['rating']?.toDouble() ?? 0.0;
    var ratingCount = data['ratingCount'] ?? 0;
    var likeCount = data['likeCount'] ?? 0;
    var timing = data['timing'] ?? 0;

    String title = data['title'] ?? 'No Name';
    String coverUrl = data['coverUrl'] ?? '';

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
    wrapItems.addAll(genreList.map((genre) => _badge(genre)).toList());
    wrapItems.add(ratingWidget);

    return Container(
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
            child: coverUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      coverUrl,
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
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
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
                      " $timing mins ",
                      style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.menu_book, size: 14, color: Colors.grey),
                    Text(
                      " $ratingCount reads ",
                      style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                    Text(
                      " $likeCount likes",
                      style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () => _confirmDelete(docId, title),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          Text(
                            " Delete",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuItem(
            "Search",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SearchPage()),
            ),
          ),
          _menuItem(
            "Insert",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => InsertPage()),
            ),
          ),
          _menuItem(
            "Edit",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EditPage()),
            ),
          ),
          _menuItem("Delete", true, () {}),
        ],
      ),
    );
  }

  Widget _menuItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.black,
              fontSize: 16,
            ),
          ),
          if (isActive)
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

  Widget _badge(String text) => Container(
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

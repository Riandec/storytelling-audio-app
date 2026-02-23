import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytelling_audio_app/core/theme_provider.dart';
import 'dart:async';
import 'package:storytelling_audio_app/screens/story_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // search bar
  String queryKeyword = '';
  Timer? debouce;
  final searchController = SearchController();
  // latest search
  List<String> latestSearches = [];
  int maxSearch = 5;

  @override
  void initState() {
    super.initState();
    searchController.addListener((){
      setState(() {});
    });
    loadSearchHistory();
  }

  @override
  void dispose() {
    debouce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  /* 
  
  QUERY DATA

  */
  Future<List<QueryDocumentSnapshot>> searchStories(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final result = await FirebaseFirestore.instance.collection('Stories').get();
    // case insensitive
    String queryLower = query.toLowerCase();
    return result.docs.where((doc){
      String title = (doc.data()['title'] as String).toLowerCase();
      return title.contains(queryLower);
    }).toList();
  }

  /* 

  reduce query load
  when user types, wait 500ms before actually starting search
  prevents excessively frequents to firestore

  */
  void debounceSearch(String query) {
    if (debouce?.isActive ?? false) {
      debouce?.cancel();
    }
    debouce = Timer(Duration(milliseconds: 800), () {
      setState(() {
        queryKeyword = query;
      });
    });
  }

  /*

  LATEST SEARCH

  */
  void addToLatestSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    setState(() {
      latestSearches.remove(keyword);
      latestSearches.insert(0, keyword);
      if (latestSearches.length > maxSearch) {
        latestSearches = latestSearches.sublist(0, maxSearch);
      }
    });
    saveSearchHistory();
  }

  // remove one search
  void removeSearch(String keyword) {
    setState(() {
      latestSearches.remove(keyword);
    });
    saveSearchHistory();
  }

  void clearAllSearches() {
    setState(() {
      latestSearches.clear();
    });
    saveSearchHistory();
  }

  /*

  SEARCH HISTORY

  */
  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('searchHistory') ?? [];
    setState(() {
      latestSearches = history;
    });
  }

  Future<void> saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', latestSearches);
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // search bar
                TextField(
                  controller: searchController,
                  onChanged: debounceSearch,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      addToLatestSearch(value.trim());
                      setState(() {
                        searchController.clear();
                        queryKeyword = '';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter the name of the story...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              queryKeyword = '';
                            });
                          } 
                        ) 
                      : null,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // feature title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Latest Search', 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              TextButton(
                                onPressed: clearAllSearches,
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // latest search
                          Expanded(
                            child:ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: latestSearches.length,
                              itemBuilder: (context, index) {
                                final keyword = latestSearches[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                  leading: Container(
                                    width: 25,
                                    height: 25,
                                    padding: EdgeInsets.only(right: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDarkTheme
                                      ? Colors.grey[900]
                                      : Color.fromRGBO(217, 217, 217, 1)
                                    ),
                                    child: Icon(
                                      Icons.history,
                                      size: 20
                                    ),
                                  ),
                                  title: Text(
                                    keyword,
                                    style: TextStyle(
                                      fontSize: 15
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => removeSearch(keyword), 
                                    icon: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDarkTheme
                                          ? Colors.grey[900]
                                          : Color.fromRGBO(217, 217, 217, 1)
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        size: 18
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    searchController.text =keyword;
                                    debounceSearch(keyword);
                                  },
                                );
                              }
                            )
                          ),
                        ]
                      ),
                      // suggestion
                      FutureBuilder<List<QueryDocumentSnapshot>>(
                        future: searchStories(queryKeyword), 
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.grey)
                              )
                            );
                          }
                          final data = snapshot.data!;
                          if (data.isEmpty) {
                            return SizedBox.shrink();
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: isDarkTheme 
                                ? Colors.grey[900] 
                                : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black)
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final doc = data[index];
                                final story = doc.data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(story['title']),
                                  onTap: () async {
                                    addToLatestSearch(story['title']);
                                    setState(() {
                                      searchController.clear();
                                      queryKeyword = '';
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoryDetailsPage(
                                          storyId: doc.id,
                                          storyData: {
                                            ...story,
                                            'id': doc.id,
                                          }
                                        )
                                      )
                                    );
                                  },
                                );
                              },
                            )
                          );
                        }
                      ),
                    ]
                  )
                )
              ],
            )
          )
        )
      )
    );
  }
}

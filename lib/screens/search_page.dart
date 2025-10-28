import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // search bar
  String queryKeyword = '';
  Timer? debouce;
  SearchController searchController = SearchController();
  // latest search
  List<String> latestSearches = [];
  int maxSearch = 5;

  @override
  void initState() {
    super.initState();
    searchController.addListener((){
      setState(() {});
    });
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
    final result = await FirebaseFirestore.instance
      .collection('Stories')
      // .where('title', isGreaterThanOrEqualTo: query)
      // .where('title', isLessThanOrEqualTo: '$query\uf8ff')
      .get();
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
  // add to latest search
  void addToLatestSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    setState(() {
      latestSearches.remove(keyword);
      latestSearches.insert(0, keyword);
      if (latestSearches.length > maxSearch) {
        latestSearches = latestSearches.sublist(0, maxSearch);
      }
    });
  }

  // remove one search
  void removeSearch(String keyword) {
    setState(() {
      latestSearches.remove(keyword);
    });
  }

  // clear all search
  void clearAllSearches() {
    setState(() {
      latestSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    hintText: 'Enter the name of the story...',
                    hintStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      color: Color(0xFFB3B3B3)
                    ),
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
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              TextButton(
                                onPressed: clearAllSearches,
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
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
                                      color: Color.fromRGBO(217, 217, 217, 1),
                                    ),
                                    child: Icon(
                                      Icons.history,
                                      color: Colors.black,
                                      size: 20
                                    ),
                                  ),
                                  title: Text(
                                    keyword,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
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
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                      ),
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.black,
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
                            return Center(child: CircularProgressIndicator());
                          }
                          final docs = snapshot.data!;
                          if (docs.isEmpty) {
                            return SizedBox.shrink();
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black)
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                final title = data['title'];
                                return ListTile(
                                  title: Text(
                                    title,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro'
                                    ),
                                  ),
                                  onTap: () async {
                                    addToLatestSearch(title);
                                    setState(() {
                                      searchController.clear();
                                      queryKeyword = '';
                                    });
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

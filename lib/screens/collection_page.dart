import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<String> likedStoryIds = [];
  List<Map<String, dynamic>> likedStoryData = [];
  List<String> finishedStoryIds = [];

  @override
  void initState() {
    super.initState();
    loadLikedStories();
    loadFinishedStories();
  }

  // load liked stories from shared preferences
  Future<void> loadLikedStories() async {
    // get id from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    likedStoryIds = prefs.getStringList('likedStoryIds') ?? [];
    // debug
    print('Liked Story IDs: $likedStoryIds');
    
    // get data from firestore
    if (likedStoryIds.isNotEmpty) {
      List<Map<String, dynamic>> stories = [];
      for (String storyId in likedStoryIds) {
        try {
          DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Stories')
            .doc(storyId)
            .get();

          if (doc.exists) {
            Map<String, dynamic> storyData = doc.data() as Map<String, dynamic>;
            storyData['documentId'] = doc.id;
            stories.add(storyData);
          }
        } catch (e) {
          print('Error loading story $storyId: $e');
        }
      }
      setState(() {
        likedStoryData = stories;
      });
    }
    //debug
    print('Loaded ${likedStoryData.length} stories');
  }

  // load finished stories from shared preferences
  Future<void> loadFinishedStories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      finishedStoryIds = prefs.getStringList('finishedStoryIds') ?? [];
    });
    //debug
    print('Finished Story IDs: $finishedStoryIds');
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 70, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // page title
              Text(
                'My Collection',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 30),
              // summary status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/story-liked.png', height: 90),
                      Text(
                        '${likedStoryData.length} ${likedStoryData.length == 1 ? "story" : "stories"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'you liked',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/time-of-listening.png', height: 90),
                      Text(
                        '0 minutes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'of listening',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/story-completed.png', height: 90),
                      Text(
                        '${finishedStoryIds.length} ${finishedStoryIds.length == 1 ? "story" : "stories"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'you finished',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10),
              // liked story list
              likedStoryData.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        'No stories in the collection',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey
                        ),
                      ),
                    )
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: likedStoryData.length,
                    itemBuilder:(context, index) {
                      final story = likedStoryData[index];
                      final isFinished = finishedStoryIds.contains(story['documentId']);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // background layer
                              Container(
                                width: 360,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color.fromRGBO(180, 225, 255, 1)
                                ),
                              ),
                              // cover image
                              Positioned(
                                left: 10,
                                bottom: 15,
                                child: Container(
                                  width: 113,
                                  height: 154,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                        spreadRadius: 0,
                                      )
                                    ]
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      story['coverUrl'],
                                      fit: BoxFit.cover
                                    )
                                  )
                                )
                              ),
                              // text
                              Positioned(
                                top: 10,
                                left: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      story['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text(isFinished ? 'Finished' : 'Recently listened'),
                                    Text(
                                      isFinished ? '100%' : '0%',
                                      style: TextStyle(
                                        fontFamily: 'Rubik Scribble',
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2
                                      ),
                                    ),
                                    Text(isFinished ? '0 minute left' : '~ 10 minute left'),
                                    SizedBox(height: 7),
                                    Stack(
                                      children: [
                                        Container(
                                          width: 190,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.black)
                                          ),
                                        ),
                                        Container(
                                          width: isFinished ? 190 : 0,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.black
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ],
          )
        )
      )
    );
  }
}
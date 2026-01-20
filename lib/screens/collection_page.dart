import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytelling_audio_app/screens/listening_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<String> likedStoryIds = [];
  List<Map<String, dynamic>> likedStoryData = [];
  List<String> finishedStoryIds = [];
  Map<String, int> listeningProgress = {};
  int accumulateTime = 0;
  Map<String, Map<String, dynamic>> storyProgress = {}; // e.g. {storyId: {percent: 50, remainingSeconds: 65}}

  @override
  void initState() {
    super.initState();
    loadLikedStories();
    loadFinishedStories();
    loadListeningTime();
    loadAllProgress();
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
      calculateProgress();
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

  // load accumulate listening time from shared preferences
  Future<void> loadListeningTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int totalSeconds = prefs.getInt('accumulateTime') ?? 0; // in seconds
    setState(() {
      accumulateTime = totalSeconds ~/ 60; // convert to minutes
    });
    //debug
    print('Accumulate listening time: $totalSeconds seconds');
  }

  // load all listening progress from shared preferences
  Future<void> loadAllProgress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? progressStr = prefs.getString('listeningProgress');
    if (progressStr != null) {
      Map<String, dynamic> progressMap = jsonDecode(progressStr);
      setState(() {
        // convert dynamic to int
        listeningProgress = progressMap.map((key, value) => MapEntry(key, value as int));
      });
      calculateProgress();
    }
  }

  // calculate story progress percentages and remaining minutes
  void calculateProgress() {
    Map<String, Map<String, dynamic>> progress = {};
    for (var story in likedStoryData) {
      String storyId = story['documentId'];
      int totalMinutes = story['timing'];
      bool isFinished = finishedStoryIds.contains(storyId);
      if (isFinished) {
        progress[storyId] = {
          'percent': 100,
          'remainingSeconds': 0
        };
      } else {
        int listenedSeconds = listeningProgress[storyId] ?? 0;
        int totalSeconds = totalMinutes * 60;
        // calculate percentage
        int percent = totalSeconds == 0 ? 0 : ((listenedSeconds / totalSeconds) * 100).round();
        if (percent > 100) {
          percent = 100;
        }
        // calculate remaining minutes
        int remainingSeconds = totalSeconds - listenedSeconds;
        if (remainingSeconds < 0) {
          remainingSeconds = 0;
        }

        progress[storyId] = {
          'percent': percent,
          'remainingSeconds': remainingSeconds
        };
      }
    }
    setState(() {
      storyProgress = progress;
    });
    //debug
    print('Story progress: $storyProgress');
  }

  String formatTime(int secs) {
    int minutes = secs ~/ 60;
    int seconds = secs % 60;
    if (secs < 60) {
      return '$secs ${secs == 1 ? "second" : "seconds"}';
    } else if (secs % 60 == 0) {
      return '$minutes ${minutes == 1 ? "minute" : "minutes"}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} ${minutes == 1 ? "minute" : "minutes"}';
    }
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
                        '$accumulateTime ${accumulateTime == 1 ? "minute" : "minutes"}',
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) => ListeningPage(storyId: story['documentId'], storyData: story)
                                      )
                                    ).then((_) {
                                      loadListeningTime();
                                      loadAllProgress();
                                    });
                                  },
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
                                  ),
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
                                    // percentage
                                    Text(
                                      '${storyProgress[story['documentId']]?['percent'] ?? 0}%',
                                      style: TextStyle(
                                        fontFamily: 'Rubik Scribble',
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2
                                      ),
                                    ),
                                    // remaining seconds
                                    Text(
                                      '~ ${formatTime(storyProgress[story['documentId']]?['remainingSeconds'] ?? story['timing'] * 60)} left'
                                    ),
                                    SizedBox(height: 7),
                                    // progress bar
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
                                          width: 190 * (storyProgress[story['documentId']]?['percent'] ?? 0) / 100,
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
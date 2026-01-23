import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:storytelling_audio_app/core/theme_provider.dart';
import 'package:storytelling_audio_app/screens/search_page.dart';
import 'package:storytelling_audio_app/screens/collection_page.dart';
import 'package:storytelling_audio_app/screens/setting_page.dart';
import 'package:storytelling_audio_app/screens/story_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0, picIndex = 0;
  List<int> genreIndex = [0];
  final _titleController = CarouselSliderController();
  final _imageController = CarouselSliderController();
  // button color
  final Color buttonActive = Color.fromRGBO(0, 85, 255, 1);
  final Color buttonInactive = Colors.white;
  // bottom nav bar list
  final List<String> labels = const ['Home', 'Search', 'Collection', 'Setting'];
  final List<double> labelDx = [0, 0, 0, 0]; // + move to the right, - move to the left
  final double labelDy = 0; // + move down, - move up
  // genres list
  final List<String> genres = const ['All', 'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Inspirational', 'Strategy', 'Thriller'];
  // star color
  final Color starActive = Color.fromRGBO(255, 227, 71, 1);
  final Color starInactive = Color.fromRGBO(217, 217, 217, 1);
  // firebase
  final CollectionReference stories = FirebaseFirestore.instance.collection('Stories');

  @override
  void initState() {
    super.initState();
  }
  
  // filter for recommended feature
  Future<List<String>> _getFinishedStoryIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('finishedStoryIds') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      SearchPage(),
      CollectionPage(),
      SettingPage(),
    ];

    return Scaffold(
      // bottom nav bar
      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CurvedNavigationBar(
            color: Colors.black,
            buttonBackgroundColor: Colors.black,
            backgroundColor: Colors.transparent,
            items: [
              Icon(Icons.home, size: 30 ,color: navIndex == 0 ? buttonActive : buttonInactive),
              Icon(Icons.search, size: 30 ,color: navIndex == 1 ? buttonActive : buttonInactive),
              Icon(Icons.book, size: 30 ,color: navIndex == 2 ? buttonActive : buttonInactive),
              Icon(Icons.settings, size: 30 ,color: navIndex == 3 ? buttonActive : buttonInactive),
            ],
            index: navIndex,
            onTap: (i) { 
              setState(() => navIndex = i);
            }
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(labels.length, (i) {
                  return Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Transform.translate(
                        offset: Offset(
                          i < labelDx.length ? labelDx[i] : 0, labelDy,
                        ),
                        child: Text(
                          labels[i], 
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold, 
                            color: navIndex == i ? buttonActive : buttonInactive 
                          )
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      body: pages[navIndex],
    );
  }

  Widget _buildHomePage() {
    // fetch isDark from ThemeProvider
    // Provider.of<ThemeProvider>(context).isDark will return true if it's dark mode
    final bool isDarkTheme = Provider.of<ThemeProvider>(context).isDark;

    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // page title
            Padding(
              padding: EdgeInsets.only(top: 70, left: 20),
              child: Text(
                "Hi, little one\nLet's explore our stories",
                style: TextStyle(
                  fontFamily: 'Darumadrop One',
                  fontSize: 32,
                  height: 1.25
                ),
              ),
            ),
            SizedBox(height: 30),
            // genre selection
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: SizedBox(
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    bool isSelected = genreIndex.contains(index);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (index == 0) {
                            genreIndex = [0];
                          } else {
                            genreIndex.remove(0);
                            if (genreIndex.contains(index)) {
                              genreIndex.remove(index);
                            } else {
                              genreIndex.add(index);
                            }
                            if (genreIndex.isEmpty) {
                              genreIndex = [0];
                            }
                          }
                        });
                      },           
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected ? buttonActive : Theme.of(context).cardColor,
                        ),
                        child: Center(
                          child: Text(
                            genres[index], 
                            style: TextStyle(
                              fontSize: 12, 
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color
                            )
                          )
                        )
                      ),
                    );
                  }
                ),
              )
            ),
            SizedBox(height: 30),
            // all stories
            StreamBuilder<QuerySnapshot>(
              stream: stories.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.grey),
                    ),
                  );
                }
                List<QueryDocumentSnapshot> data = snapshot.data!.docs; 
                if (data.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No stories available',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey
                        ),
                      ),
                    )
                  );
                }
                if (!genreIndex.contains(0) && genreIndex.isNotEmpty) {
                  List<String> selectedGenreNames = genreIndex.map((i) => genres[i]).toList();
                  data = data.where((doc) {
                    return selectedGenreNames.every((genre) => doc['genres'].contains(genre));
                  }).toList();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // carousel for images
                    CarouselSlider(
                      carouselController: _imageController,
                      items: data.map((doc) {
                        final story = doc.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoryDetailsPage(storyId: doc.id ,storyData: story)
                              )
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isDarkTheme 
                                ? [
                                  BoxShadow(
                                    color: Color.fromARGB(62, 255, 255, 255),
                                    blurRadius: 4,
                                    offset: Offset(4, 4),
                                    spreadRadius: 0,
                                  ),
                                ]
                                : [
                                  BoxShadow(
                                    color: Color.fromARGB(62, 0, 0, 0),
                                    blurRadius: 4,
                                    offset: Offset(4, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              image: DecorationImage(
                                image: NetworkImage(story['coverUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 350,
                        enlargeCenterPage: true,
                        viewportFraction: 0.5,
                        enableInfiniteScroll: data.length > 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            picIndex = index;
                          });
                          _titleController.animateToPage(index);
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    // carousel for title
                    CarouselSlider(
                      carouselController: _titleController,
                      items: data.map((doc) { 
                        final story = doc.data() as Map<String, dynamic>;
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            story['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 40,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: data.length > 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            picIndex = index;
                          });
                          _imageController.animateToPage(index);
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
            // recommended stories, unread only
            StreamBuilder<QuerySnapshot>(
              stream: stories.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.grey),
                    ),
                  );
                }
                return FutureBuilder<List<String>>(
                  future: _getFinishedStoryIds(),
                  builder: (context, finishedSnapshot) {
                    if (!finishedSnapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    List<String> finishedStoryIds = finishedSnapshot.data!;
                    final data = snapshot.data!.docs;
                    final unfinishedDocs = data.where((doc) {
                      return !finishedStoryIds.contains(doc.id);
                    }).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // recommended title
                        Padding(
                          padding: EdgeInsets.only(top: 20, left: 20),
                          child: Text(
                            "A story you haven't finish",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        unfinishedDocs.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No stories to recommend',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey
                                  ),
                                ),
                              )
                            )
                          : Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: unfinishedDocs.length,
                                  itemBuilder: (context, index) {
                                    final doc = unfinishedDocs[index];
                                    final story = doc.data() as Map<String, dynamic>;
                                    return Padding(
                                      padding: EdgeInsets.only(right: 17),
                                      child: Column(
                                        children: [
                                          // images
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => StoryDetailsPage(storyId: doc.id, storyData: story)
                                                )
                                              );
                                            },
                                            child: Container(
                                              width: 113,
                                              height: 170,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: isDarkTheme 
                                                  ? [
                                                    BoxShadow(
                                                      color: Color.fromARGB(62, 255, 255, 255),
                                                      blurRadius: 4,
                                                      offset: Offset(4, 4),
                                                      spreadRadius: 0,
                                                    ),
                                                  ]
                                                  : [
                                                    BoxShadow(
                                                      color: Color.fromARGB(62, 0, 0, 0),
                                                      blurRadius: 4,
                                                      offset: Offset(4, 4),
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                image: DecorationImage(
                                                  image: NetworkImage(story['coverUrl']),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          // story's titles
                                          SizedBox(
                                            width: 113,
                                            height: 40,
                                            child: Text(
                                              story['title'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1.25,
                                              ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                      ],
                    );
                  }
                );
                
              },
            ),
            // popular stories
            StreamBuilder<QuerySnapshot>(
              stream: stories
                  .orderBy('rating', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.grey),
                    ),
                  );
                }
                final data = snapshot.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // popular title
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 20),
                      child: Text(
                        "Most Popular",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    data.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No popular stories',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey
                              ),
                            ),
                          )
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 100),
                          child: SizedBox(
                            height: 240,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: data.length > 3 ? 3 : data.length,
                              itemBuilder: (context, index) {
                                final doc = data[index];
                                final story = doc.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: EdgeInsets.only(right: 17),
                                  child: Column(
                                    children: [
                                      // images
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => StoryDetailsPage(storyId: doc.id, storyData: story)
                                            )
                                          );
                                        },
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 113,
                                              height: 170,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: isDarkTheme 
                                                  ? [
                                                    BoxShadow(
                                                      color: Color.fromARGB(62, 255, 255, 255),
                                                      blurRadius: 4,
                                                      offset: Offset(4, 4),
                                                      spreadRadius: 0,
                                                    ),
                                                  ]
                                                  : [
                                                    BoxShadow(
                                                      color: Color.fromARGB(62, 0, 0, 0),
                                                      blurRadius: 4,
                                                      offset: Offset(4, 4),
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                image: DecorationImage(
                                                  image: NetworkImage(story['coverUrl']),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -25,
                                              child: Text(
                                                '${index+1}',
                                                style: TextStyle(
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.w900
                                                ),
                                              )
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      // rating
                                      SizedBox(
                                        width: 113,
                                        height: 20,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [ 
                                            ...List.generate(5, (starIndex){
                                              IconData iconData;
                                              Color iconColor;
                                              if (starIndex < story['rating'].floor()) {
                                                iconData = Icons.star_rounded;
                                                iconColor = starActive;
                                              } else if (starIndex < story['rating'].ceil() && story['rating'] % 1 != 0) {
                                                iconData = Icons.star_half_rounded;
                                                iconColor = starActive;
                                              } else {
                                                iconData = Icons.star_rounded;
                                                iconColor = starInactive;
                                              }
                                              return Icon(
                                                iconData,
                                                size: 12,
                                                color: iconColor,
                                              );
                                            }),
                                            SizedBox(width: 5),
                                            Text(
                                              '${story['rating'].toStringAsFixed(1)} stars',
                                              style: TextStyle(
                                                fontSize: 10
                                              ),
                                            )
                                          ]
                                        )
                                      ),
                                      SizedBox(height: 5),
                                      // story's titles
                                      SizedBox(
                                        width: 113,
                                        height: 40,
                                        child: Text(
                                          story['title'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.25,
                                          ),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                  ],
                );
              },
            )
          ],
        ),
      )
    );
  }
}

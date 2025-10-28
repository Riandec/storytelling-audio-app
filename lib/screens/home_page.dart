import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytelling_audio_app/screens/search_page.dart';
import 'package:storytelling_audio_app/screens/collection_page.dart';
import 'package:storytelling_audio_app/screens/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0, genreIndex = 0, picIndex = 0;
  final CarouselSliderController _titleController = CarouselSliderController();
  final CarouselSliderController _imageController = CarouselSliderController();
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

  @override
  void initState() {
    super.initState();
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
    return Container(
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
                    bool isSelected = genreIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          genreIndex = index;
                        });
                      },           
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected ? buttonActive : buttonInactive,
                        ),
                        child: Center(
                          child: Text(
                            genres[index], 
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 12, 
                              color: isSelected ? Colors.white : Colors.black
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

            // stream data section
            // all stories
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Stories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List storiesList = snapshot.data!.docs;
                  List<String> titles = [];
                  List<String> coverUrls = [];
                  for (var doc in storiesList) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    titles.add(data['title']);
                    coverUrls.add(data['coverUrl']);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // carousel for images
                      CarouselSlider(
                        carouselController: _imageController,
                        items: coverUrls
                            .map(
                              (coverUrl) => Container(
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x3F000000),
                                      blurRadius: 4,
                                      offset: Offset(4, 4),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(coverUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        options: CarouselOptions(
                          height: 350,
                          enlargeCenterPage: true,
                          viewportFraction: 0.5,
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
                        items: titles
                            .map(
                              (title) => Container(
                                alignment: Alignment.center,
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        options: CarouselOptions(
                          height: 40,
                          enlargeCenterPage: true,
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
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  );
                }
              },
            ),
            // unread stories
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Stories')
                  // .where('isRead', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List storiesList = snapshot.data!.docs;
                  List<String> titles = [];
                  List<String> coverUrls = [];
                  for (var doc in storiesList) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    titles.add(data['title']);
                    coverUrls.add(data['coverUrl']);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // recommended title
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20),
                        child: Text(
                          "You may also like these stories",
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: SizedBox(
                          height: 220,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 17),
                                child: Column(
                                  children: [
                                    // images
                                    Container(
                                      width: 113,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x3F000000),
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                        image: DecorationImage(
                                          image: NetworkImage(coverUrls[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // story's titles
                                    SizedBox(
                                      width: 113,
                                      height: 40,
                                      child: Text(
                                        titles[index],
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
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
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  );
                }
              },
            ),
            // popular stories
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Stories')
                  .orderBy('rating', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List storiesList = snapshot.data!.docs;
                  List<String> titles = [];
                  List<String> coverUrls = [];
                  List<double> ratings = [];
                  for (var doc in storiesList) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    titles.add(data['title']);
                    coverUrls.add(data['coverUrl']);
                    ratings.add((data['rating'] as num).toDouble());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // popular title
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20),
                        child: Text(
                          "Most Popular",
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 100),
                        child: SizedBox(
                          height: 240,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 17),
                                child: Column(
                                  children: [
                                    // images
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 113,
                                          height: 170,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x3F000000),
                                                blurRadius: 4,
                                                offset: Offset(2, 2),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                            image: DecorationImage(
                                              image: NetworkImage(coverUrls[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -25,
                                          child: Text(
                                            '${index+1}',
                                            style: TextStyle(
                                              fontFamily: 'SF Pro',
                                              fontSize: 42,
                                              fontWeight: FontWeight.w900
                                            ),
                                          )
                                        )
                                      ],
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
                                            if (starIndex < ratings[index].floor()) {
                                              iconData = Icons.star_rounded;
                                              iconColor = starActive;
                                            } else if (starIndex < ratings[index].ceil() && ratings[index] % 1 != 0) {
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
                                            '${ratings[index].toStringAsFixed(1)} stars',
                                            style: TextStyle(
                                              fontFamily: 'SF Pro',
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
                                        titles[index],
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
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
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  );
                }
              },
            )
          ],
        ),
      )
    );
  }
}

/*

Unfinished

- filter by genres
- tap navigate to story details
- recommended

*/
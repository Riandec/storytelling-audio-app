import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytelling_audio_app/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0, genreIndex = 0, picIndex = 0;
  final CarouselSliderController _titleController = CarouselSliderController();
  final CarouselSliderController _imageController = CarouselSliderController();
  // botton color
  final Color active = Color.fromRGBO(0, 85, 255, 1);
  final Color inactive = Colors.white;
  // bottom nav bar list
  final List<String> labels = const ['Home', 'Search', 'Collection', 'Setting'];
  final List<double> labelDx = [0, 0, 0, 0]; // + move to the right, - move to the left
  final double labelDy = 0; // + move down, - move up
  // genres list
  final List<String> genres = const ['All', 'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Inspirational', 'Strategy', 'Thriller'];
  // firebase
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      // bottom nav bar
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CurvedNavigationBar(
            color: Colors.black,
            buttonBackgroundColor: Colors.black,
            backgroundColor: Colors.transparent,
            items: [
              Icon(Icons.home, size: 30 ,color: navIndex == 0 ? active : inactive),
              Icon(Icons.search, size: 30 ,color: navIndex == 1 ? active : inactive),
              Icon(Icons.book, size: 30 ,color: navIndex == 2 ? active : inactive),
              Icon(Icons.settings, size: 30 ,color: navIndex == 3 ? active : inactive),
            ],
            index: navIndex,
            onTap: (i) => setState(() => navIndex = i),
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
                            color: navIndex == i ? active : inactive 
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
                            color: isSelected ? active : inactive,
                          ),
                          child: Center(
                            child: Text(
                              genres[index], 
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 12, 
                                // fontWeight: FontWeight.bold, 
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
              // stream data in firestore
              StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getStoriesStream(), 
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List storiesList = snapshot.data!.docs;
                    List<String> titles = [];
                    List<String> coverUrls = [];
                    // extract titles
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
                          items: coverUrls.map((coverUrl) => Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(4, 4),
                                  spreadRadius: 0
                                )
                              ],
                              image: DecorationImage(
                                image: NetworkImage(coverUrl),
                                fit: BoxFit.cover
                              )
                            ),
                          )).toList(), 
                          options: CarouselOptions(
                            height: 350,
                            enlargeCenterPage: true,
                            viewportFraction: 0.5,
                            onPageChanged: (index, reason) {
                              setState(() {
                                picIndex = index;
                              });
                              _titleController.animateToPage(index);
                            }
                          ),
                        ),
                        SizedBox(height: 10),
                        // carousel for title
                        CarouselSlider(
                          carouselController: _titleController,
                          items: titles.map((title) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                              ),
                            ),
                          )).toList(), 
                          options: CarouselOptions(
                            height: 40,
                            enlargeCenterPage: true,
                            // viewportFraction: 0.5,
                            onPageChanged: (index, reason) {
                              setState(() {
                                picIndex = index;
                              });
                              _imageController.animateToPage(index);
                            }
                          ),
                        ),
                        SizedBox(height: 20),
                        // feature title
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
                        // recommended
                        Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 100),
                          child: SizedBox(
                            height: 220,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder:(context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 17),
                                  child: Column (
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
                                            )
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(coverUrls[index]),
                                            fit: BoxFit.cover
                                          )
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      SizedBox(
                                        width: 113,
                                        height: 40,
                                        child: Text(
                                          titles[index],
                                          style: TextStyle(
                                            fontFamily: 'SF Pro',
                                            fontSize: 12,
                                            height: 1.25
                                          ),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ),
                                      SizedBox(height: 10),
                                      
                                    ],
                                  )
                                );
                              },
                            )
                          )
                        )
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.black),
                      )
                    );
                  }
                }
              ),
            ],
          ),
        )
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*

HOME PAGE

*/

// Section I.
class AllStoriesSection extends StatefulWidget {
  const AllStoriesSection({super.key});

  @override
  State<AllStoriesSection> createState() => _AllStoriesSectionState();
}

class _AllStoriesSectionState extends State<AllStoriesSection> {
  int picIndex = 0;
  final CarouselSliderController _titleController = CarouselSliderController();
  final CarouselSliderController _imageController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
    );
  }
}

// Section II.
class UnreadStoriesSection extends StatefulWidget {
  const UnreadStoriesSection({super.key});

  @override
  State<UnreadStoriesSection> createState() => _UnreadStoriesSectionState();
}

class _UnreadStoriesSectionState extends State<UnreadStoriesSection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
    );
  }
}

// Section III.
class PopularStoriesSection extends StatefulWidget {
  const PopularStoriesSection({super.key});

  @override
  State<PopularStoriesSection> createState() => _PopularStoriesSectionState();
}

class _PopularStoriesSectionState extends State<PopularStoriesSection> {
  // star color
  final Color active = Color.fromRGBO(255, 227, 71, 1);
  final Color inactive = Color.fromRGBO(217, 217, 217, 1);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
                                      iconColor = active;
                                    } else if (starIndex < ratings[index].ceil() && ratings[index] % 1 != 0) {
                                      iconData = Icons.star_half_rounded;
                                      iconColor = active;
                                    } else {
                                      iconData = Icons.star_rounded;
                                      iconColor = inactive;
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
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0, genreIndex = 0, picIndex = 0;
  final CarouselSliderController _titleController = CarouselSliderController();
  final CarouselSliderController _imageController = CarouselSliderController();

  final Color active = Color.fromRGBO(0, 85, 255, 1);
  final Color inactive = Colors.white;

  final List<String> labels = const ['Home', 'Search', 'Collection', 'Setting'];
  final List<double> labelDx = [0, 0, 0, 0]; // + move to the right, - move to the left
  final double labelDy = 0; // + move down, - move up

  final List<String> genres = const ['All', 'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Inspirational', 'Strategy', 'Thriller'];

  final List<String> images = const [
    '../assets/images/the-boy-who-cried-wolf.jpg',
    '../assets/images/the-hare-and-the-tortoise.jpg',
    '../assets/images/the-fox-and-the-grapes.jpg'
  ];
  final List<String> titles = const [
    'The Boy Who Cried Wolf',
    'The Hare and the Tortoise',
    'The Fox and the Grapes'
  ];

/*
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchImages();
    });
  }

  Future<void> _fetchImages() async {
    await Provider.of<StorageService>(context, listen: false).fetchImages();
  }
*/

  @override
  Widget build(BuildContext context) {
/*
    final storageService = Provider.of<StorageService>(context);
    // Fetch Image URLs From The Service
    final images = storageService.imageUrls;
*/
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      // Bottom Navigation Bar
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text(
                "Hi, little one\nLet's explore our stories",
                style: TextStyle(
                  fontFamily: 'Darumadrop One',
                  fontSize: 32,
                  height: 1.25
                ),
              ),
            ),
            SizedBox(height: 20),
            // Genre Selection
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
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
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected ? active : inactive,
                        ),
                        child: Center(
                          child: Text(
                            genres[index], 
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Carousel for Images
                  CarouselSlider(
                    carouselController: _imageController,
                    items: images.map((item) => Container(
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
                        image: DecorationImage(image: AssetImage(item), fit: BoxFit.cover)
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
                  // Carousel for Titles
                  CarouselSlider(
                    carouselController: _titleController,
                    items: titles.map((title) => Container(
                      alignment: Alignment.center,
                      child: Text(
                        title,
                        style: TextStyle(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

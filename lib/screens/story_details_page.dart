import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';

class StoryDetailsPage extends StatefulWidget {
  const StoryDetailsPage({super.key});

  @override
  State<StoryDetailsPage> createState() => _StoryDetailsPageState();
}

class _StoryDetailsPageState extends State<StoryDetailsPage> {
  final String _imagePath = 'assets/images/ChatGPT Image 11 ก.ค. 2568 15_21_12.png';
  // state for gradient colors
  // set a default color, in case the color extraction is not complete
  Color _startColor = Colors.grey.shade800;
  Color _endColor = Colors.grey.shade600;

  /*
  @override
  void initState() {
    super.initState();
    _loadAndExtractColors();
  }
  
  Future<void> _loadAndExtractColors() async {
    // wait for the image finish loading
    await precacheImage(AssetImage(_imagePath), context);
    if (!mounted) return;
    // after the image is loaded, extract colors
    setState(() {});
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // top side: show image
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _imagePath,
                      fit: BoxFit.cover,
                    ),
                    // blur effect
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              _startColor.withOpacity(0.0),
                              _startColor
                            ],
                            stops: [0.0, 0.0, 1.0],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              ),
              // bottom side: container with a color-changing gradient
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_startColor, _endColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: (){}, 
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded, 
                      color: Colors.white, 
                      size: 30
                    )
                  )
                ),
                Text(
                  'Story Details',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white
                  ),
                ),
                IconButton(
                  onPressed: (){}, 
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.favorite_outline_rounded, 
                        color: Colors.white, 
                        size: 27
                      ),
                    )
                  )
                ),
              ],
            ),
          ),
          Positioned(
            top: 420,
            left: 55,
            child: Column(
              children: [
                Text(
                  'The Hare and\nthe Tortoise',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    letterSpacing: 1,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Text(
                          'Adventure',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                            color: Colors.white
                          ),
                        )
                      )
                    ),
                    SizedBox(width: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Text(
                          'Fantasy',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                            color: Colors.white
                          ),
                        )
                      )
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.star_rounded,
                      color: Color.fromRGBO(255, 227, 71, 1),
                    ),
                    SizedBox(width: 3),
                    Text(
                      '4.9 stars',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 12,
                        color: Colors.white
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  width: 300,
                  height: 1.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '15 mins+',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '92 reads',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '57 likes',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  width: 300,
                  height: 1.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white
                  ),
                ),
              ],
            )
          ),
          Positioned(
            bottom: 280,
            left: 60,
            right: 50,
            child: Text(
              'About The Hare and the Tortoise',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
          Positioned(
            bottom: 155,
            left: 60,
            right: 50,
            child: SizedBox(
              child: Text(
                """Once upon a time in a peaceful forest, there was a swift hare and a slow but steady tortoise. One day, the hare challenged the tortoise to a race. "Let's see who can reach the finish line first!" the hare said confidently. And so the race began! The hare took off and ran far ahead. When he turned back, he couldn't even see the tortoise's shadow.""",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 12,
                  color: Colors.white
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 60,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: (){}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  icon: Icon(Icons.remove_red_eye_outlined),
                  label: Text(
                    'Preview',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: (){}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 85, 255, 1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  icon: Icon(CupertinoIcons.ear),
                  label: Text(
                    'Listen',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ],
            )
          ),

          /* 
          
          color processing (hidden, not displayed)
          used offstage to enable the widget to work without taking up ui space

          */
          Offstage(
            offstage: true, // always hide this widget
            child: ImagePixels(
              imageProvider: AssetImage(_imagePath),
              builder: (context, imgDetails) {
                // check if the color has been extracted and if imgDetails is available
                if (imgDetails.width != null) {
                  // use addPostFrameCallback to call setState after the frame build is complete
                  // prevent error "setState() called during build"
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    /*

                    key point: color selection logic
                    eyedropper: fixed x, y position

                    */  
                    // first color: select from the top 20% and the left 30% of the image
                    Color newStartColor = imgDetails.pixelColorAt!(
                      (imgDetails.width! * 0.30).round(),
                      (imgDetails.height! * 0.20).round(),
                    );
                    // second color: select from the top 80% and the left 70% of the image
                    Color newEndColor = imgDetails.pixelColorAt!(
                      (imgDetails.width! * 0.70).round(),
                      (imgDetails.height! * 0.80).round(),
                    );
                    setState(() {
                      _startColor = newStartColor;
                      _endColor = newEndColor;
                    });
                  });
                }
                // we need to return some widget, but we have hidden, so we return empty container
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytelling_audio_app/screens/listening_page.dart';

class StoryDetailsPage extends StatefulWidget {
  final String storyId;
  final Map<String, dynamic> storyData;
  const StoryDetailsPage({super.key, required this.storyId, required this.storyData});

  @override
  State<StoryDetailsPage> createState() => _StoryDetailsPageState();
}

class _StoryDetailsPageState extends State<StoryDetailsPage> {
  // state for gradient colors
  // set a default color, in case the color extraction is not complete
  Color _startColor = Colors.grey.shade800;
  Color _endColor = Colors.grey.shade600;
  // default heart button
  bool _isLiked = false;
  IconData _heartShape = Icons.favorite_outline_rounded;
  Color _heartColor = Colors.black.withOpacity(0.4);
  // firebase
  final CollectionReference stories = FirebaseFirestore.instance.collection('Stories');

  @override
  void initState() {
    super.initState();
    checkLiked();
  }

  void checkLiked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedStoryIds = prefs.getStringList('likedStoryIds') ?? [];
    setState(() {
      _isLiked = likedStoryIds.contains(widget.storyId);
      if (_isLiked) {
        _heartShape = Icons.favorite_rounded;
        _heartColor = Colors.red;
      } else {
        _heartShape = Icons.favorite_outline_rounded;
        _heartColor = Colors.black.withOpacity(0.4);
      }
    });
    // debug
    print('Liked Stories: $likedStoryIds');
    print('Current Story ID: ${widget.storyId}');
    print('isLiked: $_isLiked');
  }

  void toggleLike() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedStoryIds = prefs.getStringList('likedStoryIds') ?? [];
    setState(() {
      if (_isLiked) {
        // if liked then unlike
        likedStoryIds.remove(widget.storyId);
        _isLiked = false;
        _heartShape = Icons.favorite_outline_rounded;
        _heartColor = Colors.black.withOpacity(0.4);
        // decrease like count in firestore
        stories.doc(widget.storyId).update({'likeCount': FieldValue.increment(-1)});
        // debug
        print('Unliked: ${widget.storyId}');
      } else {
        // if not liked then like
        likedStoryIds.add(widget.storyId);
        _isLiked = true;
        _heartShape = Icons.favorite_rounded;
        _heartColor = Colors.red;
        // increase like count in firestore
        stories.doc(widget.storyId).update({'likeCount': FieldValue.increment(1)});
        // debug
        print('Liked: ${widget.storyId}');
      }
    });
    // save to shared preferences
    await prefs.setStringList('likedStoryIds', likedStoryIds);
    // debug
    print('Updated Liked Stories: $likedStoryIds');
  }

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
                    Image.network(
                      widget.storyData['content'][0]['imageUrl'],
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
          // top bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // back button
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded, 
                      color: Colors.white, 
                      size: 30
                    )
                  )
                ),
                // title
                Text(
                  'Story Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black
                  ),
                ),
                // like button
                IconButton(
                  onPressed: toggleLike,
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: _heartColor,
                      shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        _heartShape, 
                        color: Colors.white, 
                        size: 27
                      ),
                    )
                  )
                ),
              ],
            ),
          ),
          // details 
          Positioned(
            top: 420,
            left: 30,
            right: 30,
            child: Column(
              children: [
                // title
                SizedBox(
                  width: 350,
                  child: Text(
                    widget.storyData['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      letterSpacing: 1,
                      color: Colors.black
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 15),
                // genres and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(widget.storyData['genres'].length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            child: Text(
                              widget.storyData['genres'][index].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                letterSpacing: 1
                              ),
                            )
                          )
                        ),
                      );
                    }),
                    SizedBox(width: 6),
                    Icon(
                      Icons.star_rounded,
                      color: Color.fromRGBO(255, 227, 71, 1),
                    ),
                    SizedBox(width: 3),
                    Text(
                      '${widget.storyData['rating'].toStringAsFixed(1)} stars',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                SizedBox(height: 15),
                // stats
                Container(
                  width: 320,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 1.5),
                      bottom: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${widget.storyData['timing']} mins',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      SizedBox(width: 15),
                      Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${widget.storyData['ratingCount']} reads',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      SizedBox(width: 15),
                      Icon(
                        Icons.favorite_outline_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${widget.storyData['likeCount']} likes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),          
              ],
            )
          ),
          // about
          Positioned(
            top: 615,
            left: 47,
            right: 45,
            child: Text(
              'About ${widget.storyData['title']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ),
          Positioned(
            top: 640,
            left: 47,
            right: 45,
            child: SizedBox(
              child: Text(
                widget.storyData['outline'],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black
                ),
                maxLines: 8,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ),
          // button
          Positioned(
            bottom: 70,
            left: 47,
            right: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: (){}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  icon: Icon(Icons.remove_red_eye_outlined),
                  label: Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: (){
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ListeningPage(storyId: widget.storyId , storyData: widget.storyData)
                      )
                    );
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 85, 255, 1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                  icon: Icon(CupertinoIcons.ear),
                  label: Text(
                    'Listen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1
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
              imageProvider: NetworkImage(widget.storyData['content'][0]['imageUrl']),
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

/*

Unfinished

- favourite
- stat likes
- preview

*/
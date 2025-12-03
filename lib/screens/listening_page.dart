import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storytelling_audio_app/screens/rating_page.dart';

class ListeningPage extends StatefulWidget {
  final String storyId;
  final Map<String, dynamic> storyData;
  const ListeningPage({super.key, required this.storyId , required this.storyData});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    int totalPages = widget.storyData['content'].length;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.storyData['content'][currentPage]['imageUrl'],
            fit: BoxFit.cover,
          ),
          // top bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        widget.storyData['title'],
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: (){}, 
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        CupertinoIcons.slider_horizontal_3,
                        color: Colors.white, 
                        size: 27
                      ),
                    )
                  )
                ),
              ],
            ),
          ),
          // bottom bar
          Positioned(
            bottom: 50,
            left: 90,
            right: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: currentPage > 0 ? (){
                    setState(() {
                      currentPage--;
                    });
                  }
                  : null, 
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(currentPage > 0 ? 0.4 : 0.2),
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded, 
                      color: Colors.white.withOpacity(currentPage > 0 ? 1.0 : 0.6), 
                      size: 30
                    )
                  )
                ),
                Text(
                  'Page ${currentPage+1}/$totalPages',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 22,
                    color: Colors.black
                  ),
                ),
                IconButton(
                  /*
                  onPressed: currentPage < totalPages-1 ? (){
                    setState(() {
                      currentPage++;
                    });
                  }
                  : null, 
                  */

                  // to display the rating page before supporting audio play
                  onPressed: (){
                    setState(() {
                      if (currentPage < totalPages - 1) {
                        currentPage++;
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RatingPage(storyId: widget.storyId)
                          )
                        );
                      }
                    });
                  },
                  icon: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(currentPage < totalPages-1 ? 0.4 : 0.2),
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded, 
                      color: Colors.white.withOpacity(currentPage < totalPages-1 ? 1.0 : 0.6), 
                      size: 30
                    )
                  )
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

/*

Unfinished

- setting
- ui control
- sync audio

*/
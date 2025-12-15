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
  bool subtitleEnabled = false;
  bool languageEnabled = false;
  bool autoplayEnabled = false;
  bool sleepModeEnabled = false;
  double fontSize = 50.0;
  double voice = 50.0;
  double bgm = 50.0;
  double speed = 50.0;

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
                // setting button
                IconButton(
                  onPressed: (){
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setModalState) {
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: 515,
                                width: 380,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                ),
                              ),
                              Container(
                                height: 500,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // subtitle: switch
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Subtitle'),
                                          Switch(
                                            value: subtitleEnabled, 
                                            onChanged: (value){
                                              setModalState(() {
                                                subtitleEnabled = value;
                                              });
                                              setState(() {});
                                            },
                                            inactiveThumbColor: Colors.white,
                                            activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                              if (states.contains(WidgetState.selected)) {
                                                return Colors.transparent;
                                              }
                                              return Colors.transparent;
                                            }),
                                          )
                                        ],
                                      ),
                                      // language
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text('Language'),
                                          ),
                                          Switch(
                                            value: languageEnabled, 
                                            onChanged: (value){
                                              setModalState(() {
                                                languageEnabled = value;
                                              });
                                              setState(() {});
                                            },
                                            inactiveThumbColor: Colors.white,
                                            activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                              if (states.contains(WidgetState.selected)) {
                                                return Colors.transparent;
                                              }
                                              return Colors.transparent;
                                            }),
                                          )
                                        ],
                                      ),
                                      // font size: slider
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text('Font Size'),
                                          ),
                                          Column(
                                            children: [
                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                                  thumbColor: Color.fromRGBO(0, 85, 255, 1),
                                                ), 
                                                child: Slider(
                                                  value: fontSize, 
                                                  min: 0,
                                                  max: 100,
                                                  padding: EdgeInsets.zero,
                                                  onChanged: (value){
                                                    setModalState(() {
                                                      fontSize = value;
                                                    });
                                                    setState(() {});
                                                  }
                                                )
                                              ),
                                              Text(
                                                fontSize.toInt() <= 33 ? 'Small' : fontSize.toInt() <= 66 ? 'Medium' : 'Large', 
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Divider(),
                                      Text('Audio'),
                                      // voice
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text('Voice'),
                                          ),
                                          Column(
                                            children: [
                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                                  thumbColor: Color.fromRGBO(0, 85, 255, 1),
                                                ), 
                                                child: Slider(
                                                  value: voice, 
                                                  min: 0,
                                                  max: 100,
                                                  padding: EdgeInsets.zero,
                                                  onChanged: (value){
                                                    setModalState(() {
                                                      voice = value;
                                                    });
                                                    setState(() {});
                                                  }
                                                )
                                              ),
                                              Text(
                                                '${voice.toInt()}%', 
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      // bgm
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text('BGM'),
                                          ),
                                          Column(
                                            children: [
                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                                  thumbColor: Color.fromRGBO(0, 85, 255, 1),
                                                ), 
                                                child: Slider(
                                                  value: bgm, 
                                                  min: 0,
                                                  max: 100,
                                                  padding: EdgeInsets.zero,
                                                  onChanged: (value){
                                                    setModalState(() {
                                                      bgm = value;
                                                    });
                                                    setState(() {});
                                                  }
                                                )
                                              ),
                                              Text(
                                                '${bgm.toInt()}%', 
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Divider(),
                                      // speed
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Speed'),
                                          Column(
                                            children: [
                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                                  thumbColor: Color.fromRGBO(0, 85, 255, 1),
                                                ), 
                                                child: Slider(
                                                  value: speed, 
                                                  min: 0,
                                                  max: 100,
                                                  padding: EdgeInsets.zero,
                                                  onChanged: (value){
                                                    setModalState(() {
                                                      speed = value;
                                                    });
                                                    setState(() {});
                                                  }
                                                )
                                              ),
                                              Text(
                                                '${speed.toInt()}%', 
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Divider(),
                                      // autoplay
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Autoplay'),
                                          Switch(
                                            value: autoplayEnabled, 
                                            onChanged: (value){
                                              setModalState(() {
                                                autoplayEnabled = value;
                                              });
                                              setState(() {});
                                            },
                                            inactiveThumbColor: Colors.white,
                                            activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                              if (states.contains(WidgetState.selected)) {
                                                return Colors.transparent;
                                              }
                                              return Colors.transparent;
                                            }),
                                          )
                                        ],
                                      ),
                                      Divider(),
                                      // sleep mode
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Sleep Mode'),
                                          Switch(
                                            value: sleepModeEnabled, 
                                            onChanged: (value){
                                              setModalState(() {
                                                sleepModeEnabled = value;
                                              });
                                              setState(() {});
                                            },
                                            inactiveThumbColor: Colors.white,
                                            activeTrackColor: Color.fromRGBO(0, 85, 255, 1),
                                            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                              if (states.contains(WidgetState.selected)) {
                                                return Colors.transparent;
                                              }
                                              return Colors.transparent;
                                            }),
                                          )
                                        ],
                                      ),
                                      // set time
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text('Set Time'),
                                          ),
                                          Text('30 minutes')
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ],
                          );
                        });
                      },
                    );
                  }, 
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
import 'package:flutter/material.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
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
                  fontFamily: 'SF Pro',
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
                      Image.asset('assets/images/story-liked.png'),
                      Text(
                        '2 stories',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'you liked',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/time-of-listening.png'),
                      Text(
                        '15 minutes',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'of listening',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/story-completed.png'),
                      Text(
                        '1 story',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'you finished',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 70),
              Center(
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
                          child: Image.asset(
                            'assets/images/the-boy-who-cried-wolf.jpg',
                            fit: BoxFit.cover
                          )
                        )
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
                            'The Boy Who Cried Wolf',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            'Recently listened',
                            style: TextStyle(
                              fontFamily: 'SF Pro'
                            ),
                          ),
                          Text(
                            '100%',
                            style: TextStyle(
                              fontFamily: 'Rubik Scribble',
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              height: 1.2
                            ),
                          ),
                          Text(
                            '~ 0 minute left',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                            ),
                          ),
                          SizedBox(height: 7),
                          Container(
                            width: 190,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black
                            ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              )
            ],
          )
        )
      )
    );
  }
}
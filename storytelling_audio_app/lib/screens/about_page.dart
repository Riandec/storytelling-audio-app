import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<Map<String, String>> sections = [
    {
      'header': '',
      'body': '''
KidsListen Application aims to make a storytelling audio easily accessible for every child. Each story features beautiful illustrations, English narration, and Thai subtitles to help children develop bilingual and communication skills. Our goal is to foster a love for reading, improve concentration, and spark imagination through wholesome stories filled with moral values.
'''
    },
    {
      'header': 'What can this app do (Features)',
      'body': '''
-	Story Library: Browse all our stories. Use the recommended and popular sections to help you discover new stories.
-	Search: Easily find any story you're looking for.
-	Personal Collection: Save your favorite stories to listen to later. The app tracks your progress, so you can easily pick up right where you left off.
-	Emotional Narration: Every story is brought to life using Text-to-Speech (TTS) technology, with emotional tone and pacing fine-tuned by Speech Synthesis Markup Language (SSML).
'''
    },
    {
      'header': 'About the Project',
      'body': '''
This application was developed as a thesis project for the Computer Science program, Faculty of Science. The objective is to research and develop an automated system for generating storytelling audio, aiming to reduce production time and cost, allowing for the creation of great stories quickly and efficiently.
'''
    },
    {
      'header': 'Developers',
      'body': '''
Ms. Siriwan Singlor and Ms. Pitchaya Pimmahasiri (4th Year Students)
'''
    },
    {
      'header': 'Advisor',
      'body': '''
Asst. Prof. Dr. Sirak Kaewjamnong
'''
    },
    {
      'header': 'Version',
      'body': '''
1.0.0 (Prototype)
'''
    },
    {
      'header': 'Contact for information',
      'body': '''
E-mail storytellingaudio3@gmail.com
'''
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
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
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle
                ),
                child: Icon(
                  Icons.arrow_back_rounded, 
                  color: Colors.white, 
                  size: 30
                )
              )
            ),
            // header
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            // sections
            for (var data in sections)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['header']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      data['body']!,
                      textAlign: TextAlign.justify,
                    )
                  )
                ],
              )
          ],
        )
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storytelling_audio_app/core/theme_provider.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
    final String title = '''
For the [App Name] Application 
Effective as of [Date Month Year]
''';
  final String intro = '''
Thank you for using [App Name], which is part of a thesis project for the Department of Computer Science, Faculty of Science, Silpakorn University. This Privacy Policy is designed to explain how we collect, use, and manage the information we receive from your use of the application.
''';
  final List<Map<String, String>> sections = [
    {
      'header': '1.     Information We Collect',
      'body': '''
Our application is designed to be used without registration or user accounts. Therefore, we do not collect any Personally Identifiable Information (PII). However, for the purpose of analyzing and improving the application's quality, we may collect the following anonymous data:
1.1.  Usage Data
        - Stories saved to your personal library.
        - Ratings given to each story.
        - Listening progress for each story.
        -	Recent search history.
1.2.  Technical Data
        -	Device theme and notification settings.
        -	Consent to the application's privacy policy.
        - Crash reports in the event of an application failure.
'''
    },
    {
      'header': '2.     How We Use Your Information',
      'body': '''
We use the information we collect for the following purposes:
        - To analyze application usage: To understand how users interact with the app, which helps us plan for future feature development.
        - To improve our content: To evaluate the popularity of each story, which guides the development of future story selections.
        - To improve the application and maintain stability: To monitor and fix technical issues that may arise.
'''
    },
    {
      'header': "3.     Children's Privacy",
      'body': '''
This application is designed for children to use safely under parental supervision. We do not knowingly collect personally identifiable information from children. If you are a parent or guardian and you believe that your child has provided us with any information without your consent, please contact us so we can take steps to remove that information.
'''
    },
    {
      'header': '4.     Your Choices and Controls',
      'body': '''
You can control the sharing of anonymous usage data by selecting the “Decline” button below.
'''
    },
    {
      'header': '5.     Changes to This Privacy Policy',
      'body': '''
We may update this policy in the future. If we make any significant changes, we will notify you through an appropriate channel within the application.
'''
    },
    {
      'header': '6.     Contact Us',
      'body': '''
If you have any questions or concerns about this Privacy Policy, please contact the developer at storytellingaudio3@gmail.com.
'''
    }
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: (){}, 
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkTheme ? Color.fromRGBO(26, 26, 30, 1) : Colors.white,
                foregroundColor: Color.fromRGBO(0, 85, 255, 1),
                side: BorderSide(
                  color: Color.fromRGBO(0, 85, 255, 1),
                  width: 2
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              icon: Icon(Icons.clear),
              label: Text(
                'Decline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: (){}, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(0, 85, 255, 1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              icon: Icon(Icons.check),
              label: Text(
                'Accept',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1
                ),
              ),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
                // title
                Text(
                  title, 
                  style: TextStyle(
                    color: Colors.grey
                  )
                ),
                // intro
                Text(intro, textAlign: TextAlign.justify),
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
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkTheme
                      ? [
                        Color.fromRGBO(26, 26, 30, 1).withOpacity(0.0),
                        Color.fromRGBO(26, 26, 30, 1),
                      ]
                      : [
                        Colors.white.withOpacity(0.0),
                        Colors.white,
                      ],
                    stops: const [0.0, 0.9], 
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storytelling_audio_app/core/theme_provider.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'Can I listen to the stories offline?',
      'answer': 'No. This prototype version does not support offline listening or downloading stories.'
    },
    {
      'question': 'Is this application free to use?',
      'answer': 'This application is a prototype created for educational purposes only. It is not currently available for public download or general use.'
    },
    {
      'question': 'Whose voice is narrating the stories? Why does it sometimes sound robotic?',
      'answer': 'The voice is generated using Text-to-Speech (TTS) technology, which is a computer-synthesized voice. We have used SSML customization techniques to make the narration more expressive and natural.'
    },
    {
      'question': 'Will new stories be added?',
      'answer': "Not currently. For this prototype version, the story collection is fixed and is used primarily for demonstration and testing the system's functionality. No new stories will be added to this version."
    },
    {
      'question': 'Can I change the language of the narration?',
      'answer': 'No. In this version, the narration only supports English. There is currently no option to switch to other languages.'
    },
  ];
  Map<int, bool> isExpand = {};

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Provider.of<ThemeProvider>(context).isDark;

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
                  size: 30,
                )
              )
            ),
            // header
            Text(
              'Frequently Asked Questions (FAQ)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20),
            for (int i = 0; i < faqs.length; i ++) 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // question
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkTheme 
                        ? Color.fromRGBO(36, 36, 42, 1)
                        : Color.fromARGB(255, 241, 237, 244),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          isExpand[i] = !(isExpand[i] ?? false);
                        });
                      },
                      title: Text(
                        faqs[i]['question']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      trailing: Icon( isExpand[i] == true 
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded, 
                        size: 30
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // show/hidden answer
                  if (isExpand[i] == true)
                    Padding(
                      padding: EdgeInsets.only(left: 20, bottom: 20),
                      child: Text(
                        faqs[i]['answer']!
                      ),
                    ),
                ],
              )
          ],
        )
      )
    );
  }
}
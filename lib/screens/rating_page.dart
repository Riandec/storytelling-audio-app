import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  final String storyId;
  const RatingPage({super.key, required this.storyId});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int selectedRate = 0;
  final Color starActive = Color.fromRGBO(255, 227, 71, 1);
  final Color starInactive = Color.fromRGBO(217, 217, 217, 1);
  final Map<int, Map<String, String>> ratingData = {
    1: {'image': 'assets/images/one-point.png', 'mood': 'Disappointed'},
    2: {'image': 'assets/images/two-point.png', 'mood': 'Bad'},
    3: {'image': 'assets/images/three-point.png', 'mood': 'Okay'},
    4: {'image': 'assets/images/four-point.png', 'mood': 'Good'},
    5: {'image': 'assets/images/five-point.png', 'mood': 'Loved it !'},
  };
  final CollectionReference storyRef = FirebaseFirestore.instance.collection('Stories');

  // send rating to firestore
  Future<void> submitRating() async {
    if (selectedRate == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating'))
      );
      return;
    }
    try {
      // start transaction, prevent race condition
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // read and lock document
        final snapshot = await transaction.get(storyRef.doc(widget.storyId));
        if (!snapshot.exists) {
          throw Exception('Story not found');
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final currentRating = (data['rating'] as num).toDouble();
        final currentRatingCount = (data['ratingCount'] as num).toInt();
        // calculate
        final totalPoints = (currentRating * currentRatingCount) + selectedRate;
        final newRatingCount = currentRatingCount + 1;
        final newRating = totalPoints / newRatingCount;
        // update
        transaction.update(storyRef.doc(widget.storyId), {
          'rating': double.parse(newRating.toStringAsFixed(2)),
          'ratingCount': newRatingCount
        });
        // end transaction and unlock document
        
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Thank you for \nyour attention !\n\nHow was your experience\nwith this story ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Darumadrop One',
                fontSize: 32,
                height: 1.25
              ),
            ),
            SizedBox(height: 30),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: Image.asset(
                selectedRate == 0 ? 'assets/images/default-point.png' : ratingData[selectedRate]!['image']!,
                width: 150,
                height: 150,
                key: ValueKey(selectedRate),
              )
            ),
            SizedBox(height: 10),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: Text(
                selectedRate == 0 ? 'Your mood' : ratingData[selectedRate]!['mood']!,
                key: ValueKey(selectedRate),
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16
                ),
              )
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index+1;
                final isSelected = starNumber <= selectedRate;
                return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: (){
                    setState(() {
                      selectedRate = starNumber;
                    });
                  }, 
                  icon: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 70,
                    color: isSelected ? starActive : starInactive,
                  )
                );
              }),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(0, 85, 255, 1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 25)
              ),
              onPressed: submitRating,
              child: Text('Submit')
            )
          ],
        ),
      )
    );
  }
}
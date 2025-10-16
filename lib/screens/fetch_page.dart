/*

tutorial: https://www.youtube.com/watch?v=iQOvD0y-xnw&list=LL&index=4

*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytelling_audio_app/models/story.dart';
import 'package:storytelling_audio_app/services/firestore_service.dart';

class FetchPage extends StatefulWidget {
  const FetchPage({super.key});

  @override
  State<FetchPage> createState() => _FetchPageState();
}

class _FetchPageState extends State<FetchPage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Service Example'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getStoriesStream(), 
        builder: (context, snapshot) {
          // if we have data, get all the docs
          if (snapshot.hasData) {
            List storiesList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
              itemCount: storiesList.length,
              itemBuilder: (context, index) {
                // get each indevidual doc
                DocumentSnapshot document = storiesList[index];
                String storyId = document.id;

                // get story from each doc
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String title = data['title'];

                // display as a list tile
                return ListTile(
                  title: Text(title)
                );
              }
            );
          } else {
            return const Text('No data');
          }
        }
      )
    );
  }
}
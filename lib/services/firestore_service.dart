/*

tutorial: https://www.youtube.com/watch?v=iQOvD0y-xnw&list=LL&index=4

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytelling_audio_app/models/story.dart';

class FirestoreService {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // late final CollectionReference<Story> _storiesRef;
  final CollectionReference stories = FirebaseFirestore.instance.collection('Stories');

  /* custom object version

  FirestoreService() {
    _storiesRef = _db.collection('Stories').withConverter<Story>(
      fromFirestore: Story.fromFirestore,
      toFirestore: (Story story, _) => story.toFirestore(),
    );
  }

  */

  // CREATE
  Future<void> createStory(Story story) {
    // return _storiesRef.add(story);
    return stories.add({
      'title': story.title,
      'coverUrl': story.coverUrl,
      'audioUrl': story.audioUrl,
      'genres': story.genres,
      'timing': story.timing,
      'content': story.content?.map((c) => c.toFirestore()).toList()
    });
  }

  // READ
  Stream<QuerySnapshot> getStoriesStream() {
    // return _storiesRef.snapshots();
    return stories.snapshots();
  }

  // UPDATE
  Future<void> updateStory(String storyId, Story newStory)  {
    // return _storiesRef.doc(storyId).update(newStory);
    return stories.doc(storyId).update({
      'title': newStory.title,
      'coverUrl': newStory.coverUrl,
      'audioUrl': newStory.audioUrl,
      'genres': newStory.genres,
      'timing': newStory.timing,
      'content': newStory.content?.map((c) => c.toFirestore()).toList()
    });
  }

  // DELETE
  Future<void> deleteStory(String storyId) {
    // return _storiesRef.doc(storyId).delete();
    return stories.doc(storyId).delete();
  }
}
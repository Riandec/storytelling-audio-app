import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytelling_audio_app/models/story.dart';
import 'package:storytelling_audio_app/services/firestore_service.dart';
import 'package:storytelling_audio_app/services/storage_service.dart';

class StoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<Story> _stories = [];
  List<Story> get stories => _stories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StoryProvider() {
    fetchStories();
  }

  // READ
  void fetchStories() {
    _firestoreService.getStoriesStream().listen((storiesData) {
      _stories = storiesData;
      notifyListeners();
    }).onError((error) {
      print("Error fetching stories: $error");
    });
  }

  // CREATE
  Future<void> addStory({
    required String title,
    required List<String> genres,
    required int timing,
    required List<Content> content,
    required File coverImageFile,
    required File audioFile,
  }) async {
    _setLoading(true);
    try {
      // 1. create a new document id
      final storyId = FirebaseFirestore.instance.collection('stories').doc().id;

      // 2. upload image and audio files to storage
      final coverUrl = await _storageService.uploadFile('stories/$storyId/cover.jpg', coverImageFile);
      final audioUrl = await _storageService.uploadFile('stories/$storyId/audio.mp3', audioFile);

      // 3. create a story object
      final newStory = Story(
        id: storyId,
        title: title,
        coverUrl: coverUrl,
        audioUrl: audioUrl,
        genres: genres,
        timing: timing,
        content: content,
      );

      // 4. save to firestore
      await _firestoreService.createStory(newStory);

    } catch (e) {
      print("Error in addStory provider: $e");
    } finally {
      _setLoading(false);
    }
  }

  // UPDATE (ex: updateing only title or timing)
  Future<void> updateStoryDetails(String storyId, {String? newTitle, int? newTiming}) async {
    _setLoading(true);
    try {
      final Map<String, dynamic> updateData = {};
      if (newTitle != null) updateData['title'] = newTitle;
      if (newTiming != null) updateData['timing'] = newTiming;

      if (updateData.isNotEmpty) {
        await _firestoreService.updateStory(storyId, updateData);
      }
    } catch (e) {
      print("Error in updateStoryDetails provider: $e");
    } finally {
      _setLoading(false);
    }
  }

  // DELETE
  Future<void> deleteStory(Story story) async {
    _setLoading(true);
    try {
      // 1. delete files in storage
      await _storageService.deleteFileByUrl(story.coverUrl);
      await _storageService.deleteFileByUrl(story.audioUrl);
      // loop to delete all content images
      for (var scene in story.content) {
        await _storageService.deleteFileByUrl(scene.imageUrl);
      }

      // 2. delete document in firestore
      await _firestoreService.deleteStory(story.id);

    } catch (e) {
      print("Error in deleteStory provider: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String> _uploadFile(String path, {File? file, Uint8List? bytes}) async {
    final ref = FirebaseStorage.instance.ref(path);
    UploadTask uploadTask;

    if (kIsWeb && bytes != null) {
      // Web upload
      uploadTask = ref.putData(bytes);
    } else if (!kIsWeb && file != null) {
      // Mobile/Desktop upload
      uploadTask = ref.putFile(file);
    } else {
      throw Exception('File or bytes must be provided.');
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
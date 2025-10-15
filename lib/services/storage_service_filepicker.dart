import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class StorageServiceFilepicker with ChangeNotifier {
  // firebase storage
  final firebaseStorage = FirebaseStorage.instance;

  // images and audios are stored in firebase as download URLs
  List<String> _imageUrls = [];
  List<String> _audioUrls = [];

  // loading status
  bool _isLoading = false;

  // uploading status
  bool _isUploading = false;

  /*

  GETTERS

  */

  List<String> get imageUrls => _imageUrls;
  List<String> get audioUrls => _audioUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  /*

  READ FILE

  */

  Future<void> fetchImages() async {
    // start loading..
    _isLoading = true;

    // get the list under the directory: media/
    final ListResult result = await firebaseStorage.ref('media/images/').listAll();

    // get the download URLs for each image
    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    // upload URLs
    _imageUrls = urls;

    // loading finished..
    _isLoading = false;

    // update UI
    notifyListeners();
  }

  Future<void> fetchAudios() async {
    _isLoading = true;

    final ListResult result = await firebaseStorage.ref('media/audios/').listAll();
    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    _audioUrls = urls;
    _isLoading = false;
    notifyListeners();
  }

  /*

  DELETE FILE

  - images are stored as download URLs
  eg: https://firebasestorage.googleapis.com/v0/b/fir-masterclass.../media/image_name.jpg/

  - in order to delete, we need to know only the path of this image store in firebase
  ie: media/image_name.jpg

  */

  Future<void> deleteImages(String imageUrl) async {
    try {
      // remove from local list
      _imageUrls.remove(imageUrl);

      // get path name and delete from firebase
      final String path = extractPathFromUrl(imageUrl);
      await firebaseStorage.ref(path).delete();
    } catch (e) {
      print('Error deleting image: $e');
    }

    // update UI
    notifyListeners();
  }

  Future<void> deleteAudio(String audioUrl) async {
    try {
      _audioUrls.remove(audioUrl);
      final String path = extractPathFromUrl(audioUrl);
      await firebaseStorage.ref(path).delete();
    } catch (e) {
      print('Error deleting audio: $e');
    }
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);

    // extracting the part of the url we need
    String encodedPath = uri.pathSegments.last;

    // url decoding the path
    return Uri.decodeComponent(encodedPath);
  }

  /*

  UPLOAD FILE

  */

  Future<void> uploadImage() async {
    // start upload..
    _isUploading = true;
    // update UI
    notifyListeners();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    // user cancelled the picker
    if (result == null) {
      _isUploading = false;
      notifyListeners();
      return;
    }

    File file = File(result.files.single.path!);
    String extension = result.files.single.extension ?? 'jpg';

    try {
      // define the path in storage
      String filePath = 'media/images/${DateTime.now().millisecondsSinceEpoch}.$extension';

      // upload the file to firebase
      await firebaseStorage.ref(filePath).putFile(file);

      // after uploading.. fetch the download URL
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      // update the image urls list and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadAudio() async {
    _isUploading = true;
    notifyListeners();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result == null) {
      _isUploading = false;
      notifyListeners();
      return;
    }

    File file = File(result.files.single.path!);
    String extension = result.files.single.extension ?? 'mp3';

    try {
      String filePath = 'media/audios/${DateTime.now().millisecondsSinceEpoch}.$extension';
      await firebaseStorage.ref(filePath).putFile(file);
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      _audioUrls.add(downloadUrl);
      notifyListeners();
    } catch (e) {
      print('Error uploading audio: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}

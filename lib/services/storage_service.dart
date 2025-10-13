import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService with ChangeNotifier {
  // firebase storage
  final firebaseStorage = FirebaseStorage.instance;

  // images are stored in firebase as download URLs
  List<String> _imageUrls = [];

  // loading status
  bool _isLoading = false;

  // uploading status
  bool _isUploading = false;

  /*

  GETTERS

  */

  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  /*

  READ IMAGES

  */

  Future<void> fetchImages() async {
    // start loading..
    _isLoading = true;

    // get the list under the directory: media/
    final ListResult result = await firebaseStorage.ref('media/').listAll();

    // get the download URLs for each image
    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    // upload URLs
    _imageUrls = urls;

    // loading finished..
    _isLoading = false;

    // update UI
    notifyListeners();
  }

  /*

  DELETE IMAGE

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

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);

    // extracting the part of the url we need
    String encodedPath = uri.pathSegments.last;

    // url decoding the path
    return Uri.decodeComponent(encodedPath);
  }

  /*

  UPLOAD IMAGE

  */

  Future<void> uploadImage() async {
    // start upload..
    _isUploading = true;
    // update UI
    notifyListeners();

    // pick an image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return; // user cancelled the picker

    File file = File(image.path);

    try {
      // define the path in storage
      String filePath = 'media/${DateTime.now()}.jpg';

      // upload the file to firebase
      await firebaseStorage.ref((filePath).putFile(file));

      // after uploading.. fetch the download URL
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();

      // update the image urls list and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    } catch (e) {
      print('Error uploading image: $e');
    }

    finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}

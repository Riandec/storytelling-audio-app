/*

for testing fetch file in storage

*/

import 'package:flutter/material.dart';
import 'package:storytelling_audio_app/services/storage_service.dart';
import 'package:provider/provider.dart';

class FetchImage extends StatefulWidget {
  const FetchImage({super.key});

  @override
  State<FetchImage> createState() => _FetchImageState();
}

class _FetchImageState extends State<FetchImage> {
  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    await Provider.of<StorageService>(context, listen: false).fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, child) {
        // list of image urls
        final List<String> imageUrls = storageService.imageUrls;

        // page ui
        return Scaffold(
          body: ListView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              // get each individual image
              final String imageUrl = imageUrls[index];
              // image post ui
              return Image.network(imageUrl, fit: BoxFit.cover);
            }
          )
        );
      }
    );
  }
}
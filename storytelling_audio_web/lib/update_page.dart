import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'insert_page.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class StorySection {
  TextEditingController enController = TextEditingController();
  TextEditingController thController = TextEditingController();
  Uint8List? newImageBytes;
  String? oldImageUrl;
  String? imageName;
  String? audioUrl;
  int pageTiming = 0;

  StorySection({
    this.oldImageUrl,
    this.audioUrl,
    this.pageTiming = 0,
    String en = '',
    String th = '',
  }) {
    enController.text = en;
    thController.text = th;
  }
}

class UpdatePage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const UpdatePage({super.key, required this.docId, required this.data});

  @override
  State<UpdatePage> createState() => _UpdateStoryPageState();
}

class _UpdateStoryPageState extends State<UpdatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _outlineController = TextEditingController();

  final List<String> _allGenres = [
    "Adventure",
    "Fantasy",
    "Fable",
    "Comedy",
    "Drama",
    "Horror",
    "Sci-Fi",
    "Romance",
    "Action",
  ];

  List<String> _selectedGenres = [];
  Uint8List? _newCoverBytes;
  String? _oldCoverUrl;
  String? _coverName;

  List<StorySection> _sections = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final String _googleApiKey = "AIzaSyAc7hw8Y-A1ioaMe0WROmFJU5T0gx8IfPQ";
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _outlineController.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    _nameController.text = widget.data['title'] ?? '';

    _outlineController.text = widget.data['outline'] ?? '';

    var genresData = widget.data['genres'];
    if (genresData is List) {
      _selectedGenres = genresData.map((e) => e.toString()).toList();
    } else if (genresData is String && genresData.isNotEmpty) {
      _selectedGenres = genresData.split(',').map((e) => e.trim()).toList();
    }

    _oldCoverUrl = widget.data['coverUrl'];

    if (widget.data['content'] != null) {
      List<dynamic> contents = widget.data['content'];
      for (var item in contents) {
        Map<String, dynamic> textMap = item['text'] != null
            ? Map<String, dynamic>.from(item['text'])
            : {};

        _sections.add(
          StorySection(
            oldImageUrl: item['imageUrl'],
            audioUrl: item['audioUrl'],
            pageTiming: item['pageTiming'] ?? 0,
            en: textMap['en'] ?? '',
            th: textMap['th'] ?? '',
          ),
        );
      }
    } else {
      _sections.add(StorySection());
    }
  }

  Future<Map<String, dynamic>?> _showAudioPreviewDialog(
    String textEn,
    String textTh,
  ) async {
    String textToPlay = textEn.isNotEmpty ? textEn : textTh;
    String langCode = textEn.isNotEmpty ? "en-US" : "th-TH";

    if (textToPlay.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No text to generate audio!")));
      return null;
    }

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AudioPreviewDialog(
          text: textToPlay,
          langCode: langCode,
          apiKey: _googleApiKey,
        );
      },
    );
  }

  Future<void> _pickCoverImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _newCoverBytes = bytes;
        _coverName = pickedFile.name;
      });
    }
  }

  Future<void> _pickContentImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _sections[index].newImageBytes = bytes;
        _sections[index].imageName = pickedFile.name;
      });
    }
  }

  void _addNewSection() => setState(() => _sections.add(StorySection()));

  void _removeSection(int index) {
    if (_sections.length > 1) setState(() => _sections.removeAt(index));
  }

  Future<void> _updateData() async {
    setState(() => _isUploading = true);
    try {
      String finalCoverUrl = _oldCoverUrl ?? '';
      if (_newCoverBytes != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'story_covers/${DateTime.now().millisecondsSinceEpoch}_$_coverName',
        );
        await storageRef.putData(_newCoverBytes!);
        finalCoverUrl = await storageRef.getDownloadURL();
      }

      int totalSeconds = 0;

      List<Map<String, dynamic>> contentDataList = [];
      for (int i = 0; i < _sections.length; i++) {
        String finalContentUrl = _sections[i].oldImageUrl ?? '';
        if (_sections[i].newImageBytes != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
            'story_contents/${DateTime.now().millisecondsSinceEpoch}_${i}_${_sections[i].imageName}',
          );
          await storageRef.putData(_sections[i].newImageBytes!);
          finalContentUrl = await storageRef.getDownloadURL();
        }

        totalSeconds += _sections[i].pageTiming;

        contentDataList.add({
          'id': i,
          'imageUrl': finalContentUrl,
          'audioUrl': _sections[i].audioUrl ?? '',
          'pageTiming': _sections[i].pageTiming,
          'text': {
            'en': _sections[i].enController.text,
            'th': _sections[i].thController.text,
          },
          'style': 'default',
        });
      }

      int totalMinutes = (totalSeconds / 60).ceil();
      if (totalSeconds > 0 && totalMinutes == 0) totalMinutes = 1;

      await FirebaseFirestore.instance
          .collection('Stories')
          .doc(widget.docId)
          .update({
            'title': _nameController.text,
            'outline': _outlineController.text,
            'genres': _selectedGenres,
            'coverUrl': finalCoverUrl,
            'content': contentDataList,
            'timing': totalMinutes,
            'updated_at': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update Success!")));

      Navigator.pop(context, true);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Story',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        elevation: 0,
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('*Cover Image', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildImageBox(
                        _newCoverBytes,
                        _oldCoverUrl,
                        _pickCoverImage,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              _nameController,
                              "Story's Name",
                              height: 80,
                            ),

                            SizedBox(height: 15),
                            _buildTextField(
                              _outlineController,
                              "Outline",
                              minLines: 3,
                              maxLines: 10,
                            ),

                            SizedBox(height: 15),
                            Text(
                              "Genre",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 5),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _allGenres.map((genre) {
                                return FilterChip(
                                  label: Text(genre),
                                  selected: _selectedGenres.contains(genre),
                                  selectedColor: Colors.blue.shade100,
                                  checkmarkColor: Colors.blue,
                                  labelStyle: TextStyle(
                                    color: _selectedGenres.contains(genre)
                                        ? Colors.blue.shade900
                                        : Colors.black,
                                    fontSize: 12,
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected)
                                        _selectedGenres.add(genre);
                                      else
                                        _selectedGenres.remove(genre);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 40),

                  ..._sections.asMap().entries.map((entry) {
                    int index = entry.key;
                    StorySection section = entry.value;
                    bool hasAudio =
                        section.audioUrl != null &&
                        section.audioUrl!.isNotEmpty;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index + 1} Content Image',
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeSection(index),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageBox(
                              entry.value.newImageBytes,
                              entry.value.oldImageUrl,
                              () => _pickContentImage(index),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextField(
                                    entry.value.enController,
                                    "Storyline EN",
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: 10),
                                  _buildTextField(
                                    entry.value.thController,
                                    "Storyline TH",
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: 15),

                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          Map<String, dynamic>? result =
                                              await _showAudioPreviewDialog(
                                                section.enController.text,
                                                section.thController.text,
                                              );
                                          if (result != null) {
                                            setState(() {
                                              section.audioUrl = result['url'];
                                              section.pageTiming =
                                                  result['duration'] ?? 0;
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text("Audio Updated!"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          hasAudio
                                              ? Icons.check_circle
                                              : Icons.volume_up,
                                          color: hasAudio
                                              ? Colors.green
                                              : Colors.blue,
                                        ),
                                        label: Text(
                                          hasAudio
                                              ? "Audio Ready (Edit)"
                                              : "Generate Audio",
                                          style: TextStyle(
                                            color: hasAudio
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: hasAudio
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (hasAudio) ...[
                                        SizedBox(width: 10),
                                        IconButton(
                                          icon: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.green,
                                            size: 35,
                                          ),
                                          tooltip: "Play Current Audio",
                                          onPressed: () {
                                            _previewPlayer.play(
                                              UrlSource(section.audioUrl!),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                      ],
                    );
                  }).toList(),

                  Center(
                    child: IconButton(
                      onPressed: _addNewSection,
                      icon: Icon(Icons.add_circle_outline, size: 40),
                    ),
                  ),
                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        "Update Changes",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildImageBox(
    Uint8List? newBytes,
    String? oldUrl,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: newBytes != null
              ? Image.memory(newBytes, fit: BoxFit.cover)
              : (oldUrl != null && oldUrl.isNotEmpty)
              ? Image.network(
                  oldUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: Colors.grey),
                )
              : Icon(Icons.add_a_photo, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    int minLines = 1,
    double? height,
  }) {
    return Container(
      height: height,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextField(
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(top: 5),
            ),
          ),
        ],
      ),
    );
  }
}

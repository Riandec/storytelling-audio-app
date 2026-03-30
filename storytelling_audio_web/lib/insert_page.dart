import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_page.dart';
import 'edit_page.dart';
import 'delete_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'ssml_editor_page.dart'; // Import หน้า SSML Editor

class StorySection {
  TextEditingController enController = TextEditingController();
  TextEditingController thController = TextEditingController();
  Uint8List? imageBytes;
  String? imageName;
  String? audioUrl;

  int pageTiming = 0;

  StorySection();
}

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<InsertPage> {
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
  Uint8List? _coverImageBytes;
  String? _coverName;
  List<StorySection> _sections = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final String _googleApiKey =
      "AIzaSyAc7hw8Y-A1ioaMe0WROmFJU5T0gx8IfPQ"; // ใส่ Key ของคุณ
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _sections.add(StorySection());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _outlineController.dispose();
    _previewPlayer.dispose();
    super.dispose();
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

  void _addNewSection() => setState(() => _sections.add(StorySection()));

  void _removeSection(int index) {
    if (_sections.length > 1) setState(() => _sections.removeAt(index));
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _coverImageBytes = bytes;
          _coverName = pickedFile.name;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _pickContentImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _sections[index].imageBytes = bytes;
          _sections[index].imageName = pickedFile.name;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter Story Name")));
      return;
    }
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one Genre")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? coverUrl;
      if (_coverImageBytes != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'story_covers/${DateTime.now().millisecondsSinceEpoch}_$_coverName',
        );
        await storageRef.putData(_coverImageBytes!);
        coverUrl = await storageRef.getDownloadURL();
      }

      int totalSeconds = 0;

      List<Map<String, dynamic>> contentDataList = [];
      for (int i = 0; i < _sections.length; i++) {
        String? contentUrl;
        if (_sections[i].imageBytes != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
            'story_contents/${DateTime.now().millisecondsSinceEpoch}_${i}_${_sections[i].imageName}',
          );
          await storageRef.putData(_sections[i].imageBytes!);
          contentUrl = await storageRef.getDownloadURL();
        }

        totalSeconds += _sections[i].pageTiming;

        contentDataList.add({
          'id': i,
          'audioUrl': _sections[i].audioUrl ?? '',
          'imageUrl': contentUrl ?? '',

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

      await FirebaseFirestore.instance.collection('Stories').add({
        'title': _nameController.text,
        'outline': _outlineController.text,
        'genres': _selectedGenres,
        'coverUrl': coverUrl ?? '',
        'content': contentDataList,
        'likeCount': 0,
        'rating': 0,
        'ratingCount': 0,
        'timing': totalMinutes,
        'id': '',
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save Success!")));

      _nameController.clear();
      _outlineController.clear();
      setState(() {
        _selectedGenres.clear();
        _coverImageBytes = null;
        _sections = [StorySection()];
      });
    } catch (e) {
      print("Error: $e");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Storytelling Management',
          style: GoogleFonts.shortStack(color: Colors.black, fontSize: 28),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.black,
              size: 35,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) {
              final user = FirebaseAuth.instance.currentUser;
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Signed in as",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        user?.email ?? "Guest",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopMenu(),
                  Divider(thickness: 1),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('*Cover Image', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImagePickerBox(
                              onTap: _pickCoverImage,
                              imageBytes: _coverImageBytes,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTextFieldContainer(
                                    controller: _nameController,
                                    label: "Story's Name",
                                    height: 80,
                                  ),

                                  SizedBox(height: 15),

                                  _buildTextFieldContainer(
                                    controller: _outlineController,
                                    label: "Outline",
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
                                        selected: _selectedGenres.contains(
                                          genre,
                                        ),
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
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 20),
                        ..._sections.asMap().entries.map((entry) {
                          int index = entry.key;
                          StorySection section = entry.value;

                          bool hasAudio = section.audioUrl != null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${index + 1} Content Image',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (_sections.length > 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeSection(index),
                                    ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildImagePickerBox(
                                    onTap: () => _pickContentImage(index),
                                    imageBytes: section.imageBytes,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildTextFieldContainer(
                                          controller: section.enController,
                                          label: "Storyline EN",
                                          maxLines: 3,
                                        ),
                                        SizedBox(height: 10),
                                        _buildTextFieldContainer(
                                          controller: section.thController,
                                          label: "Storyline TH",
                                          maxLines: 3,
                                        ),
                                        SizedBox(height: 15),

                                        Row(
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                // ✅ (แก้ไข) รับค่ากลับมาเป็น Map
                                                Map<String, dynamic>? result =
                                                    await _showAudioPreviewDialog(
                                                      section.enController.text,
                                                      section.thController.text,
                                                    );

                                                if (result != null) {
                                                  setState(() {
                                                    section.audioUrl =
                                                        result['url'];
                                                    // ✅ (แก้ไข) เก็บเวลา pageTiming
                                                    section.pageTiming =
                                                        result['duration'] ?? 0;
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Audio Saved & Ready!",
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
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
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                tooltip: "Play Saved Audio",
                                                onPressed: () {
                                                  _previewPlayer.play(
                                                    UrlSource(
                                                      section.audioUrl!,
                                                    ),
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
                            icon: Icon(Icons.add_circle_outline, size: 45),
                            tooltip: "Add next content block",
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _uploadToFirebase,
                            icon: Icon(Icons.cloud_upload),
                            label: Text("Save to Cloud"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTopMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuItem(
            "Search",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            ),
          ),
          _menuItem("Insert", true, () {}),
          _menuItem(
            "Edit",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EditPage()),
            ),
          ),
          _menuItem(
            "Delete",
            false,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DeletePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.black,
              fontSize: 16,
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 50,
              color: Colors.blue,
              margin: EdgeInsets.only(top: 5),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePickerBox({
    required VoidCallback onTap,
    Uint8List? imageBytes,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: imageBytes == null
              ? Border.all(color: Colors.grey.shade300)
              : null,
        ),
        child: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(imageBytes, fit: BoxFit.cover),
              )
            : Icon(Icons.image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextFieldContainer({
    required TextEditingController controller,
    required String label,
    String? hint,
    double? height,
    int maxLines = 1,
    int minLines = 1,
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
              hintText: hint,
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

class AudioPreviewDialog extends StatefulWidget {
  final String text;
  final String langCode;
  final String apiKey;

  const AudioPreviewDialog({
    super.key,
    required this.text,
    required this.langCode,
    required this.apiKey,
  });

  @override
  State<AudioPreviewDialog> createState() => _AudioPreviewDialogState();
}

class _AudioPreviewDialogState extends State<AudioPreviewDialog> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isAudioLoaded = false;
  Uint8List? _audioBytes;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted)
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _fetchAndPlay() async {
    if (widget.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      String url =
          "https://texttospeech.googleapis.com/v1/text:synthesize?key=${widget.apiKey}";
      String voiceName = widget.langCode == "th-TH"
          ? "th-TH-Standard-A"
          : "en-US-Journey-F";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "input": {"text": widget.text},
          "voice": {"languageCode": widget.langCode, "name": voiceName},
          "audioConfig": {"audioEncoding": "MP3"},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String audioContent = jsonResponse['audioContent'];
        _audioBytes = base64Decode(audioContent);

        String audioUrl = "data:audio/mp3;base64,$audioContent";
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));

        if (mounted) setState(() => _isAudioLoaded = true);
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("TTS Error: ${response.statusCode}")),
          );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _togglePlay() async {
    if (_isLoading) return;
    if (!_isAudioLoaded) {
      await _fetchAndPlay();
    } else {
      if (_isPlaying)
        await _audioPlayer.pause();
      else
        await _audioPlayer.resume();
    }
  }

  Future<void> _uploadAudio() async {
    if (_audioBytes == null) return;
    setState(() => _isLoading = true);

    try {
      String fileName =
          "tts_audio_${DateTime.now().millisecondsSinceEpoch}.mp3";
      final storageRef = FirebaseStorage.instance.ref().child(
        'story_audios/$fileName',
      );
      await storageRef.putData(
        _audioBytes!,
        SettableMetadata(contentType: 'audio/mpeg'),
      );
      String downloadUrl = await storageRef.getDownloadURL();

      if (mounted) {
        // ✅ (แก้ไข) ส่งกลับเป็น Map มีทั้ง URL และ Duration (วินาที)
        Navigator.pop(context, {
          'url': downloadUrl,
          'duration': _duration.inSeconds,
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.all(20),
      content: Container(
        width: 500,
        height: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              "Audio Preview (TTS)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _togglePlay,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.volume_up_rounded,
                      size: 80,
                      color: _isPlaying ? Colors.blue : Colors.black,
                    ),
            ),
            SizedBox(height: 10),
            Text(
              _isLoading
                  ? "Processing..."
                  : (_isPlaying ? "Playing..." : "Tap to Play"),
              style: TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(_formatTime(_position), style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble().clamp(
                        0,
                        _duration.inSeconds.toDouble(),
                      ),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(position);
                      },
                      activeColor: Colors.black,
                      inactiveColor: Colors.grey.shade300,
                    ),
                  ),
                  Text(_formatTime(_duration), style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SsmlEditorPage(
                              text: widget.text,
                              langCode: widget.langCode,
                              apiKey: widget.apiKey,
                            ),
                          ),
                        );

                        if (result != null && mounted) {
                          String audioUrl = result;
                          await _audioPlayer.setSourceUrl(audioUrl);
                          await Future.delayed(Duration(milliseconds: 500));
                          Duration? d = await _audioPlayer.getDuration();

                          Navigator.pop(context, {
                            'url': audioUrl,
                            'duration': d?.inSeconds ?? 0,
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Customize\nSSML",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAudioLoaded ? _uploadAudio : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Use This\nAudio",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

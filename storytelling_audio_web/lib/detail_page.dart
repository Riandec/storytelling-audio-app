import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPage({super.key, required this.data});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _playingIndex = -1;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String url, int index) async {
    try {
      if (_playingIndex == index) {
        if (_isPlaying) {
          await _audioPlayer.pause();
          setState(() => _isPlaying = false);
        } else {
          await _audioPlayer.resume();
          setState(() => _isPlaying = true);
        }
      } else {
        await _audioPlayer.stop();
        setState(() {
          _playingIndex = index;
          _isPlaying = true;
        });
        await _audioPlayer.play(UrlSource(url));
      }

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _playingIndex = -1;
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot play audio")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> contents = widget.data['content'] ?? [];
    List<dynamic> genresRaw = widget.data['genres'] ?? [];
    List<String> genreList = genresRaw.isEmpty
        ? ["General"]
        : genresRaw.map((e) => e.toString()).toList();

    var rating = widget.data['rating'] ?? 0.0;
    var likeCount = widget.data['likeCount'] ?? 0;
    var ratingCount = widget.data['ratingCount'] ?? 0;

    String coverUrl = widget.data['coverUrl'] ?? '';
    String title = widget.data['title'] ?? 'No Title';
    String outline = widget.data['outline'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: coverUrl.isNotEmpty
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          width: 200,
                          child: Icon(Icons.image, size: 50),
                        ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

            if (outline.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Outline",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      outline,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],

            // Tags & Stats
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: genreList.map((g) => _tag(g)).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Stats Row
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                Text(
                  " $rating stars   ",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.menu_book, color: Colors.blueGrey, size: 18),
                Text(
                  " $ratingCount reads   ",
                  style: TextStyle(color: Colors.grey[800]),
                ),
                Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                Text(
                  " $likeCount likes",
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),

            Divider(height: 40, thickness: 1),

            // Contents List
            if (contents.isEmpty)
              Center(
                child: Text(
                  "No content available.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  var item = contents[index];
                  String? audioUrl = item['audioUrl'];
                  String? imageUrl = item['imageUrl'];

                  Map<String, dynamic> textMap = item['text'] != null
                      ? Map<String, dynamic>.from(item['text'])
                      : {};
                  String textEn = textMap['en'] ?? '';
                  String textTh = textMap['th'] ?? '';

                  bool isThisPlaying = (_playingIndex == index && _isPlaying);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                          ),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.broken_image),
                                  ),
                                )
                              : Icon(Icons.image, color: Colors.grey),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (audioUrl != null && audioUrl.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _toggleAudio(audioUrl, index),
                                    icon: Icon(
                                      isThisPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.volume_up_rounded,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      isThisPlaying ? "Pause" : "Listen",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isThisPlaying
                                          ? Colors.orange
                                          : Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 8,
                                      ),
                                      minimumSize: Size(0, 36),
                                    ),
                                  ),
                                ),
                              Text(
                                textEn,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                textTh,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: TextStyle(color: Colors.blue[800], fontSize: 12)),
  );
}

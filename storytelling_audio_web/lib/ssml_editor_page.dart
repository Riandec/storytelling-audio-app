import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;

class SsmlEditorPage extends StatefulWidget {
  final String text;
  final String langCode;
  final String apiKey;

  const SsmlEditorPage({
    super.key,
    required this.text,
    required this.langCode,
    required this.apiKey,
  });

  @override
  State<SsmlEditorPage> createState() => _SsmlEditorPageState();
}

class _SsmlEditorPageState extends State<SsmlEditorPage> {
  late SsmlStylingController _ssmlController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;

  String _selectedPitch = 'default';
  String _selectedRate = 'default';
  String _selectedVolume = 'default';
  String _selectedEmphasis = 'none';
  String _selectedBreak = 'none';

  @override
  void initState() {
    super.initState();
    _ssmlController = SsmlStylingController(text: widget.text);
  }

  @override
  void dispose() {
    _ssmlController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _previewAudio(String textToPlay) async {
    setState(() => _isLoading = true);
    try {
      String url =
          "https://texttospeech.googleapis.com/v1/text:synthesize?key=${widget.apiKey}";
      String voiceName = widget.langCode == "th-TH"
          ? "th-TH-Neural2-C"
          : "en-US-Neural2-F";

      String finalSsml = textToPlay.contains("<speak>")
          ? textToPlay
          : "<speak>$textToPlay</speak>";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "input": {"ssml": finalSsml},
          "voice": {"languageCode": widget.langCode, "name": voiceName},
          "audioConfig": {"audioEncoding": "MP3"},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final bytes = base64Decode(jsonResponse['audioContent']);
        final blob = html.Blob([bytes], 'audio/mpeg');
        final audioUrl = html.Url.createObjectUrlFromBlob(blob);
        final audio = html.AudioElement(audioUrl);
        audio.play();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndUpload() async {
    setState(() => _isLoading = true);
    try {
      String url =
          "https://texttospeech.googleapis.com/v1/text:synthesize?key=${widget.apiKey}";
      String voiceName = widget.langCode == "th-TH"
          ? "th-TH-Neural2-C"
          : "en-US-Neural2-F";

      String finalSsml = _ssmlController.text.contains("<speak>")
          ? _ssmlController.text
          : "<speak>${_ssmlController.text}</speak>";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "input": {"ssml": finalSsml},
          "voice": {"languageCode": widget.langCode, "name": voiceName},
          "audioConfig": {"audioEncoding": "MP3"},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final bytes = base64Decode(jsonResponse['audioContent']);
        String fileName =
            "ssml_audio_${DateTime.now().millisecondsSinceEpoch}.mp3";
        final storageRef = FirebaseStorage.instance.ref().child(
          'story_audios/$fileName',
        );
        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'audio/mpeg'),
        );
        String downloadUrl = await storageRef.getDownloadURL();
        if (mounted) Navigator.pop(context, downloadUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gen Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Upload Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applySsmlTags() {
    final text = _ssmlController.text;
    final selection = _ssmlController.selection;
    if (selection.start == -1 || selection.end == -1) return;

    String selectedText = text.substring(selection.start, selection.end);

    List<String> prosodyAttributes = [];
    if (_selectedPitch != 'default')
      prosodyAttributes.add('pitch="$_selectedPitch"');
    if (_selectedRate != 'default')
      prosodyAttributes.add('rate="$_selectedRate"');
    if (_selectedVolume != 'default')
      prosodyAttributes.add('volume="$_selectedVolume"');

    String prefix = "";
    String suffix = "";

    if (prosodyAttributes.isNotEmpty) {
      prefix += '<prosody ${prosodyAttributes.join(" ")}>';
      suffix = '</prosody>' + suffix;
    }

    if (_selectedEmphasis != 'none') {
      prefix += '<emphasis level="$_selectedEmphasis">';
      suffix = '</emphasis>' + suffix;
    }

    String newText = "$prefix$selectedText$suffix";

    if (_selectedBreak != 'none') {
      String time = "500ms";
      if (_selectedBreak == 'x-weak') time = "250ms";
      if (_selectedBreak == 'medium') time = "1s";
      if (_selectedBreak == 'strong') time = "1.5s";
      if (_selectedBreak == 'x-strong') time = "2s";
      newText += '<break time="$time"/>';
    }

    final newValue = text.replaceRange(selection.start, selection.end, newText);
    _ssmlController.value = TextEditingValue(
      text: newValue,
      selection: TextSelection.collapsed(
        offset: selection.start + newText.length,
      ),
    );
    Navigator.pop(context);
  }

  void _showEditDialog() {
    setState(() {
      _selectedPitch = 'default';
      _selectedRate = 'default';
      _selectedVolume = 'default';
      _selectedEmphasis = 'none';
      _selectedBreak = 'none';
    });

    String selectedText = _ssmlController.text.substring(
      _ssmlController.selection.start,
      _ssmlController.selection.end,
    );
    int wordCount = selectedText.trim().isEmpty
        ? 0
        : selectedText.trim().split(RegExp(r'\s+')).length;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 400,
                padding: EdgeInsets.all(25),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customize Speech",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Editing $wordCount words",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 15),
                      Divider(),

                      _buildSectionHeader("Voice Qualities"),
                      _buildStyledDropdown(
                        "Pitch (ระดับเสียง):",
                        ["default", "x-low", "low", "medium", "high", "x-high"],
                        _selectedPitch,
                        (val) => setStateDialog(() => _selectedPitch = val!),
                      ),
                      _buildStyledDropdown(
                        "Rate (ความเร็ว):",
                        [
                          "default",
                          "x-slow",
                          "slow",
                          "medium",
                          "fast",
                          "x-fast",
                        ],
                        _selectedRate,
                        (val) => setStateDialog(() => _selectedRate = val!),
                      ),
                      _buildStyledDropdown(
                        "Volume (ความดัง):",
                        [
                          "default",
                          "silent",
                          "x-soft",
                          "soft",
                          "medium",
                          "loud",
                          "x-loud",
                        ],
                        _selectedVolume,
                        (val) => setStateDialog(() => _selectedVolume = val!),
                      ),

                      SizedBox(height: 10),

                      _buildSectionHeader("Effects & Pauses"),
                      _buildStyledDropdown(
                        "Emphasis (เน้นคำ):",
                        ["none", "strong", "moderate", "reduced"],
                        _selectedEmphasis,
                        (val) => setStateDialog(() => _selectedEmphasis = val!),
                      ),
                      _buildStyledDropdown(
                        "Break (หยุดพัก):",
                        ["none", "x-weak", "medium", "strong", "x-strong"],
                        _selectedBreak,
                        (val) => setStateDialog(() => _selectedBreak = val!),
                      ),

                      SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text("Cancel"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applySsmlTags,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Apply Tags",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildStyledDropdown(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Container(
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: Icon(Icons.arrow_drop_down, size: 20),
                style: TextStyle(color: Colors.black87, fontSize: 13),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Storytelling Management',
          style: GoogleFonts.shortStack(color: Colors.black, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          Icon(Icons.account_circle, color: Colors.black, size: 35),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Original Text:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _previewAudio(widget.text),
                icon: Icon(Icons.volume_up, size: 20),
                label: Text("Play Original (Plain)"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey),
                ),
              ),
              Divider(height: 40, thickness: 1),
              Text(
                "SSML Editor (Styled):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "Highlight text to apply effects like pitch, speed, volume, etc.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Listener(
                  onPointerUp: (event) {
                    if (_ssmlController.selection.isValid &&
                        !_ssmlController.selection.isCollapsed) {
                      _showEditDialog();
                    }
                  },
                  child: TextField(
                    controller: _ssmlController,
                    maxLines: 10,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Highlight text to edit...",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _previewAudio(_ssmlController.text),
                    icon: Icon(Icons.play_arrow),
                    label: Text("Play Edited Audio"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: Text("Go Back"),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _generateAndUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("Generate & Save"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SsmlStylingController extends TextEditingController {
  SsmlStylingController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> children = [];
    final String text = value.text;
    final RegExp tagPattern = RegExp(r'(<[^>]+>)');

    int currentIndex = 0;

    for (final Match match in tagPattern.allMatches(text)) {
      if (match.start > currentIndex) {
        String plainText = text.substring(currentIndex, match.start);
        children.add(TextSpan(text: plainText, style: style));
      }

      String tag = match.group(0)!;
      TextStyle tagStyle = TextStyle(color: Colors.grey.shade400, fontSize: 12);

      if (tag.contains('break')) {
        tagStyle = TextStyle(
          color: Colors.orange.shade800,
          backgroundColor: Colors.orange.shade50,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        );
      } else if (tag.contains('prosody')) {
        tagStyle = TextStyle(
          color: Colors.purple.shade700,
          backgroundColor: Colors.purple.shade50,
          fontSize: 12,
        );
      } else if (tag.contains('emphasis')) {
        tagStyle = TextStyle(
          color: Colors.blue.shade700,
          backgroundColor: Colors.blue.shade50,
          fontSize: 12,
        );
      }

      children.add(TextSpan(text: tag, style: tagStyle));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      children.add(TextSpan(text: text.substring(currentIndex), style: style));
    }

    return TextSpan(style: style, children: children);
  }
}

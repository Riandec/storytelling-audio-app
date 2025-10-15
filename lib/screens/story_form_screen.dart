import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

// Helper class (เหมือนเดิม)
class SceneFormState {
  final TextEditingController thController = TextEditingController();
  final TextEditingController enController = TextEditingController();
  final TextEditingController pitchController = TextEditingController(text: '1.0');
  String emphasis = 'none';
  
  // CHANGED: We now need to handle both File for mobile and bytes for web
  File? imageFile; // For mobile/desktop
  Uint8List? imageBytes; // For web preview
  String? existingImageUrl; // For edit mode
}

class StoryFormScreen extends StatefulWidget {
  final Story? story;

  const StoryFormScreen({super.key, this.story});

  @override
  State<StoryFormScreen> createState() => _StoryFormScreenState();
}

class _StoryFormScreenState extends State<StoryFormScreen> {
  // Properties and initState/dispose methods (เหมือนเดิม)
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timingController;
  late TextEditingController _genreController;

  // CHANGED: State for files now includes bytes for web
  File? _coverImageFile;
  Uint8List? _coverImageBytes;
  File? _audioFile;
  // Uint8List? _audioBytes;

  List<String> _genres = [];
  List<SceneFormState> _sceneStates = [];
  bool get _isEditMode => widget.story != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final s = widget.story!;
      _titleController = TextEditingController(text: s.title);
      _timingController = TextEditingController(text: s.timing.toString());
      _genres = List.from(s.genres);
      _sceneStates = s.content.map((scene) {
        return SceneFormState()
          ..thController.text = scene.text.th
          ..enController.text = scene.text.en
          ..pitchController.text = scene.style.pitch.toString()
          ..emphasis = scene.style.emphasis
          ..existingImageUrl = scene.imageUrl;
      }).toList();
    } else {
      _titleController = TextEditingController();
      _timingController = TextEditingController();
      _sceneStates.add(SceneFormState());
    }
    _genreController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timingController.dispose();
    _genreController.dispose();
    for (var sceneState in _sceneStates) {
      sceneState.thController.dispose();
      sceneState.enController.dispose();
      sceneState.pitchController.dispose();
    }
    super.dispose();
  }

  // --- Functions for picking files ---

  // --- CHANGED: Use FilePicker for cover image ---
  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // NEW: Make sure we get bytes on web
    );
    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _coverImageBytes = result.files.single.bytes;
        } else {
          _coverImageFile = File(result.files.single.path!);
        }
      });
    }
  }

  // --- UNCHANGED: This function already uses FilePicker ---
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  // --- CHANGED: Use FilePicker for scene image ---
  Future<void> _pickSceneImage(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // NEW: Make sure we get bytes on web
    );
    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _sceneStates[index].imageBytes = result.files.single.bytes;
        } else {
          _sceneStates[index].imageFile = File(result.files.single.path!);
        }
        _sceneStates[index].existingImageUrl = null;
      });
    }
  }

  // Functions for managing UI elements and saving form (เหมือนเดิมทั้งหมด)
  void _addGenre() {
    if (_genreController.text.isNotEmpty && !_genres.contains(_genreController.text)) {
      setState(() {
        _genres.add(_genreController.text.trim());
        _genreController.clear();
      });
    }
  }

  void _addScene() {
    setState(() {
      _sceneStates.add(SceneFormState());
    });
  }

  void _removeScene(int index) {
    setState(() {
      _sceneStates.removeAt(index);
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_isEditMode && (_coverImageFile == null || _audioFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select cover image and audio file.')),
      );
      return;
    }

    final storyProvider = Provider.of<StoryProvider>(context, listen: false);

    try {
      if (_isEditMode) {
        await storyProvider.updateStoryDetails(
          widget.story!.id,
          newTitle: _titleController.text,
          newTiming: int.tryParse(_timingController.text) ?? 0,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story updated successfully!')),
        );
      } else {
        List<Content> content = _sceneStates.map((state) {
          return Content(
            text: TextLang(th: state.thController.text, en: state.enController.text),
            style: Style(emphasis: state.emphasis, pitch: state.pitchController.text),
            imageUrl: '', 
          );
        }).toList();

        await storyProvider.addStory(
          title: _titleController.text,
          genres: _genres,
          timing: int.tryParse(_timingController.text) ?? 0,
          content: content,
          coverImageFile: _coverImageFile!,
          audioFile: _audioFile!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story created successfully!')),
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save story: $e')),
      );
    }
  }

  // Build method and Widget builder methods (เหมือนเดิมทั้งหมด)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Story' : 'Add New Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Story Details'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _timingController,
                decoration: const InputDecoration(labelText: 'Timing (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter the timing' : null,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Genres'),
              _buildGenreInput(),
              const SizedBox(height: 20),
              _buildSectionTitle('Files'),
              _buildCoverImagePicker(),
              const SizedBox(height: 10),
              _buildAudioPicker(),
              const SizedBox(height: 20),
              _buildSectionTitle('Scenes Content'),
              _buildScenesList(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Scene'),
                onPressed: _addScene,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildGenreInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Add a genre'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addGenre,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _genres.map((genre) => Chip(
            label: Text(genre),
            onDeleted: () {
              setState(() {
                _genres.remove(genre);
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCoverImagePicker() {
    Widget imagePreview;
    
    // CHANGED: Conditional rendering for image preview
    if (_coverImageBytes != null) { // 1. Check for web picked file
      imagePreview = Image.memory(_coverImageBytes!, height: 100, fit: BoxFit.cover);
    } else if (_coverImageFile != null) { // 2. Check for mobile picked file
      imagePreview = Image.file(_coverImageFile!, height: 100, fit: BoxFit.cover);
    } else if (_isEditMode && widget.story!.coverUrl.isNotEmpty) { // 3. Check for existing image
      imagePreview = Image.network(widget.story!.coverUrl, height: 100, fit: BoxFit.cover);
    } else { // 4. Fallback placeholder
      imagePreview = Container(
        height: 100,
        width: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }

    return Row(
      children: [
        imagePreview,
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _pickCoverImage,
          child: const Text('Select Cover'),
        ),
      ],
    );
  }
  
  Widget _buildAudioPicker() {
    return Row(
      children: [
        const Icon(Icons.audiotrack, color: Colors.blue),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _audioFile?.path.split('/').last ?? (_isEditMode ? 'Existing audio file' : 'No audio selected'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ElevatedButton(
          onPressed: _pickAudioFile,
          child: const Text('Select Audio'),
        ),
      ],
    );
  }

  Widget _buildScenesList() {
    if (_sceneStates.isEmpty) {
      return const Text('No scenes yet. Add one below!');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sceneStates.length,
      itemBuilder: (context, index) {
        return _buildSceneCard(index);
      },
    );
  }

  Widget _buildSceneCard(int index) {
    final sceneState = _sceneStates[index];
    Widget imagePreview;
    
    // CHANGED: Conditional rendering for scene image preview
    if (sceneState.imageBytes != null) { // 1. Check for web picked file
      imagePreview = Image.memory(sceneState.imageBytes!, height: 80, fit: BoxFit.cover);
    } else if (sceneState.imageFile != null) { // 2. Check for mobile picked file
      imagePreview = Image.file(sceneState.imageFile!, height: 80, fit: BoxFit.cover);
    } else if (sceneState.existingImageUrl != null && sceneState.existingImageUrl!.isNotEmpty) { // 3. Check for existing image
      imagePreview = Image.network(sceneState.existingImageUrl!, height: 80, fit: BoxFit.cover);
    } else { // 4. Fallback placeholder
      imagePreview = Container(height: 80, width: 80, color: Colors.grey[200]);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Scene ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
                if (_sceneStates.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeScene(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(controller: sceneState.thController, decoration: const InputDecoration(labelText: 'Text (TH)')),
            TextFormField(controller: sceneState.enController, decoration: const InputDecoration(labelText: 'Text (EN)')),
            const SizedBox(height: 10),
            Row(
              children: [
                imagePreview,
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickSceneImage(index),
                  child: const Text('Scene Image'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String title;
  final String coverUrl;
  final String audioUrl;
  final List<String> genres;
  final int timing;
  final List<Content> content;

  Story ({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.audioUrl,
    required this.genres,
    required this.timing,
    required this.content
  });

  // to create a story instance from firestore document
  factory Story.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      title: data['title'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      genres: List<String>.from(data['genres'] ?? []),
      timing: data['timing'] ?? 0,
      content: (data['content'] as List<dynamic>? ?? [])
          .map((contentData) => Content.fromMap(contentData))
          .toList(),
    );
  }

  // to convert a story instance to a map for firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'genres': genres,
      'timing': timing,
      'content': content.map((content) => content.toFirestore()).toList(),
    };
  }
}

// object in the content array
class Content {
  final TextLang text;
  final Style style;
  final String imageUrl;

  Content({
    required this.text,
    required this.style,
    required this.imageUrl,
  });

  factory Content.fromMap(Map<String, dynamic> map){
    return Content(
      text: TextLang.fromMap(map['text'] ?? {}),
      style: Style.fromMap(map['style'] ?? {}),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text.toFirestore(),
      'style': style.toFirestore(),
      'imageUrl': imageUrl,
    };
  }
}

// object in the text field
class TextLang {
  final String th;
  final String en;

  TextLang({
    required this.th,
    required this.en,
  });

  factory TextLang.fromMap(Map<String, dynamic> map) {
    return TextLang(
      th: map['th'] ?? '',
      en: map['en'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'th': th, 'en': en};
  }
}

// object in the style field
class Style {
  final String emphasis;
  final String pitch;

  Style({
    required this.emphasis,
    required this.pitch,
  });

  factory Style.fromMap(Map<String, dynamic> map) {
    return Style(
      emphasis: map['emphasis'] ?? 'none',
      pitch: map['pitch'] ?? 'medium',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'emphasis': emphasis, 'pitch': pitch};
  }
}
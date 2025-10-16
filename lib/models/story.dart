import 'package:cloud_firestore/cloud_firestore.dart';

/*

Doc: https://firebase.google.com/docs/firestore/query-data/get-data?hl=th

*/

class Story {
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? audioUrl;
  final List<String>? genres;
  final int? timing;
  final List<Content>? content;

  Story ({
    this.id,
    this.title,
    this.coverUrl,
    this.audioUrl,
    this.genres,
    this.timing,
    this.content
  });

  // to create a story instance from firestore document
  factory Story.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Story(
      id: data?['id'],
      title: data?['title'],
      coverUrl: data?['coverUrl'],
      audioUrl: data?['audioUrl'],
      genres: data?['genres'] is Iterable ? List.from(data? ['genres']) : null,
      timing: data?['timing'],
      content: (data?['content'] as List<dynamic>?)
          ?.map((item) => Content.fromFirestore(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // to convert a story instance to a map for firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (genres != null) 'genres': genres,
      if (timing != null) 'timing': timing,
      if (content != null) 'content': content
    };
  }
}

class Content {
  final TextLang? text;
  final Style? style;
  final String? imageUrl;

  Content({
    this.text,
    this.style,
    this.imageUrl
  });

  factory Content.fromFirestore(Map<String, dynamic> map){
    return Content(
      text: map['text'] != null 
          ? TextLang.fromFirestore(map['text'] as Map<String, dynamic>) : null,
      style: map['style'] != null 
          ? Style.fromFirestore(map['style'] as Map<String, dynamic>) : null,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (text != null) 'text': text!.toFirestore(),
      if (style != null) 'style': style!.toFirestore(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class TextLang {
  final String? th;
  final String? en;

  TextLang({
    this.th,
    this.en,
  });

  factory TextLang.fromFirestore(Map<String, dynamic> map) {
    return TextLang(
      th: map['th'],
      en: map['en'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (th != null) 'th': th,
      if (en != null) 'en': en,
    };
  }
}

// object in the style field
class Style {
  final String? emphasis;
  final String? pitch;

  Style({
    this.emphasis,
    this.pitch,
  });

  factory Style.fromFirestore(Map<String, dynamic> map) {
    return Style(
      emphasis: map['emphasis'] ?? 'none',
      pitch: map['pitch'] ?? 'medium',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (emphasis != null) 'emphasis': emphasis,
      if (pitch != null) 'pitch': pitch,
    };
  }
}
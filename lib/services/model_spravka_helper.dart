class SpravkaContent {
  final String type;
  final String? text;
  final String? imagePath;
  final String? url;

  SpravkaContent({required this.type, this.text, this.imagePath, this.url});

  factory SpravkaContent.fromJson(Map<String, dynamic> json) {
    return SpravkaContent(
      type: json['type'],
      text: json['text'],
      imagePath: json['imagePath'],
      url: json['url'],
    );
  }
}

class Spravka {
  final int id;
  final String title;
  final List<SpravkaContent> content;

  Spravka({required this.id, required this.title, required this.content});

  factory Spravka.fromJson(Map<String, dynamic> json) {
    var list = json['content'] as List;
    List<SpravkaContent> contentList = list.map((i) => SpravkaContent.fromJson(i)).toList();

    return Spravka(
      id: json['id'],
      title: json['title'],
      content: contentList,
    );
  }
}

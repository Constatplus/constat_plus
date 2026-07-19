class Photo {
  final String id;
  final String path;
  final String caption;

  const Photo({
    this.id = '',
    this.path = '',
    this.caption = '',
  });

  Photo copyWith({
    String? id,
    String? path,
    String? caption,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      caption: caption ?? this.caption,
    );
  }
}
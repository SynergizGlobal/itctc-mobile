class FormAttachment {
  const FormAttachment({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
  });

  final String id;
  final String name;
  final String path;
  final int size;
  final String extension;

  factory FormAttachment.fromMap(Map<String, dynamic> map) {
    return FormAttachment(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      path: map['path']?.toString() ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      extension: map['extension']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'size': size,
        'extension': extension,
      };
}

List<FormAttachment> parseAttachments(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map>()
      .map((item) => FormAttachment.fromMap(Map<String, dynamic>.from(item)))
      .where((item) => item.id.isNotEmpty && item.path.isNotEmpty)
      .toList();
}

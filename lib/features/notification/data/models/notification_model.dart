class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _read(json, 'notificationId').toString(),
      title: _read(json, 'title')?.toString() ?? '',
      content: _read(json, 'content')?.toString() ?? '',
      type: _read(json, 'type')?.toString(),
      isRead: _read(json, 'isRead') == true,
      createdAt:
          DateTime.tryParse(_read(json, 'createdAt')?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}

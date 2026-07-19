class NotificationModel {
  const NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _readStringAny(json, const ['notificationId', 'id']) ?? '',
      userId: _readStringAny(json, const ['userId']),
      title: _readStringAny(json, const ['title']) ?? 'FlexFit',
      message: _readStringAny(json, const ['message', 'content', 'body']) ?? '',
      type: _readStringAny(json, const ['type', 'notificationType']),
      isRead: _readBoolAny(json, const ['isRead', 'read']) ?? false,
      createdAt:
          DateTime.tryParse(
            _readStringAny(json, const ['createdAt', 'createdDate']) ?? '',
          ) ??
          DateTime.now(),
    );
  }

}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}

String? _readStringAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _read(json, key)?.toString().trim();
    if (value != null && value.isNotEmpty && value.toLowerCase() != 'null') {
      return value;
    }
  }
  return null;
}

bool? _readBoolAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _read(json, key);
    if (value is bool) {
      return value;
    }
    final text = value?.toString().trim().toLowerCase();
    if (text == 'true' || text == '1') {
      return true;
    }
    if (text == 'false' || text == '0') {
      return false;
    }
  }
  return null;
}

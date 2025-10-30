class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? avatarEmoji;
  final DateTime joinedDate;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.avatarEmoji,
    required this.joinedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'avatarEmoji': avatarEmoji,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatarEmoji: json['avatarEmoji'] as String?,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? avatarEmoji,
    DateTime? joinedDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}

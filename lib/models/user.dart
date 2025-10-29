class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedDate;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.joinedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    DateTime? joinedDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}

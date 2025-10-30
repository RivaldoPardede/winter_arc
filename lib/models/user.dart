class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? avatarEmoji;
  final DateTime joinedDate;
  final int currentStreak;
  final DateTime? lastStreakUpdate;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.avatarEmoji,
    required this.joinedDate,
    this.currentStreak = 0,
    this.lastStreakUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'avatarEmoji': avatarEmoji,
      'joinedDate': joinedDate.toIso8601String(),
      'currentStreak': currentStreak,
      'lastStreakUpdate': lastStreakUpdate?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatarEmoji: json['avatarEmoji'] as String?,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastStreakUpdate: json['lastStreakUpdate'] != null
          ? DateTime.parse(json['lastStreakUpdate'] as String)
          : null,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? avatarEmoji,
    DateTime? joinedDate,
    int? currentStreak,
    DateTime? lastStreakUpdate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      joinedDate: joinedDate ?? this.joinedDate,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStreakUpdate: lastStreakUpdate ?? this.lastStreakUpdate,
    );
  }
}

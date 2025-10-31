import 'package:cloud_firestore/cloud_firestore.dart';

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

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) throw ArgumentError('DateTime value cannot be null');
    
    // Handle Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }
    
    // Handle String (ISO8601)
    if (value is String) {
      return DateTime.parse(value);
    }
    
    // If it's already a DateTime
    if (value is DateTime) {
      return value;
    }
    
    throw ArgumentError('Unable to parse DateTime from type ${value.runtimeType}');
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) return null;
    return _parseDateTime(value);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatarEmoji: json['avatarEmoji'] as String?,
      joinedDate: _parseDateTime(json['joinedDate']),
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastStreakUpdate: _parseOptionalDateTime(json['lastStreakUpdate']),
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

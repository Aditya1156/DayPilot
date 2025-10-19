import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model with Firebase integration
class UserProfile {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActive;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.createdAt,
    required this.lastActive,
    this.preferences = const {},
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'preferences': preferences,
    };
  }

  // Create from Firestore document
  factory UserProfile.fromFirestore(Map<String, dynamic> doc) {
    return UserProfile(
      uid: doc['uid'] ?? '',
      email: doc['email'] ?? '',
      username: doc['username'] ?? 'User',
      photoUrl: doc['photoUrl'],
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (doc['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: doc['preferences'] ?? {},
    );
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? uid,
    String? email,
    String? username,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      preferences: preferences ?? this.preferences,
    );
  }
}

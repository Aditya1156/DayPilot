class User {
  final String id;
  final String name;
  final String email;
  final String timezone;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.timezone,
    this.preferences = const {},
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'timezone': timezone,
      'preferences': preferences,
    };
  }

  // Create from Map (Firestore)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      timezone: map['timezone'],
      preferences: map['preferences'] ?? {},
    );
  }
}
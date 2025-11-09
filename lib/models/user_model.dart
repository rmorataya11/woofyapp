class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name:
          json['user_metadata']?['name'] as String? ?? json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['user_metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'user_metadata': metadata,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresAt;
  final int expiresIn;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
      expiresIn: json['expires_in'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }

  bool get isNearExpiry {
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inMinutes < 5;
  }

  bool get isExpired {
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isAfter(expiryDate);
  }
}

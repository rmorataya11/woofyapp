class Profile {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? location;
  final String? bio;
  final String? avatarUrl;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.location,
    this.bio,
    this.avatarUrl,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'bio': bio,
      'avatar_url': avatarUrl,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Profile(id: $id, name: $name, email: $email)';
}

class UserPreferences {
  final bool pushNotifications;
  final bool emailUpdates;
  final bool smsReminders;
  final String theme;
  final String language;
  final NotificationSettings notificationSettings;
  final PrivacySettings privacy;

  UserPreferences({
    required this.pushNotifications,
    required this.emailUpdates,
    required this.smsReminders,
    required this.theme,
    required this.language,
    required this.notificationSettings,
    required this.privacy,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      pushNotifications: json['push_notifications'] as bool? ?? true,
      emailUpdates: json['email_updates'] as bool? ?? true,
      smsReminders: json['sms_reminders'] as bool? ?? false,
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'es',
      notificationSettings: NotificationSettings.fromJson(
        json['notification_settings'] as Map<String, dynamic>? ?? {},
      ),
      privacy: PrivacySettings.fromJson(
        json['privacy'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications': pushNotifications,
      'email_updates': emailUpdates,
      'sms_reminders': smsReminders,
      'theme': theme,
      'language': language,
      'notification_settings': notificationSettings.toJson(),
      'privacy': privacy.toJson(),
    };
  }

  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      pushNotifications: true,
      emailUpdates: true,
      smsReminders: false,
      theme: 'system',
      language: 'es',
      notificationSettings: NotificationSettings.defaultSettings(),
      privacy: PrivacySettings.defaultSettings(),
    );
  }

  UserPreferences copyWith({
    bool? pushNotifications,
    bool? emailUpdates,
    bool? smsReminders,
    String? theme,
    String? language,
    NotificationSettings? notificationSettings,
    PrivacySettings? privacy,
  }) {
    return UserPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      smsReminders: smsReminders ?? this.smsReminders,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacy: privacy ?? this.privacy,
    );
  }
}

class NotificationSettings {
  final bool appointments;
  final bool reminders;
  final bool promotions;
  final bool system;

  NotificationSettings({
    required this.appointments,
    required this.reminders,
    required this.promotions,
    required this.system,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      appointments: json['appointments'] as bool? ?? true,
      reminders: json['reminders'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      system: json['system'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments,
      'reminders': reminders,
      'promotions': promotions,
      'system': system,
    };
  }

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      appointments: true,
      reminders: true,
      promotions: false,
      system: true,
    );
  }

  NotificationSettings copyWith({
    bool? appointments,
    bool? reminders,
    bool? promotions,
    bool? system,
  }) {
    return NotificationSettings(
      appointments: appointments ?? this.appointments,
      reminders: reminders ?? this.reminders,
      promotions: promotions ?? this.promotions,
      system: system ?? this.system,
    );
  }
}

class PrivacySettings {
  final bool shareLocation;
  final bool dataAnalytics;
  final String profileVisibility;

  PrivacySettings({
    required this.shareLocation,
    required this.dataAnalytics,
    required this.profileVisibility,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      shareLocation: json['share_location'] as bool? ?? true,
      dataAnalytics: json['data_analytics'] as bool? ?? true,
      profileVisibility: json['profile_visibility'] as String? ?? 'private',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'share_location': shareLocation,
      'data_analytics': dataAnalytics,
      'profile_visibility': profileVisibility,
    };
  }

  factory PrivacySettings.defaultSettings() {
    return PrivacySettings(
      shareLocation: true,
      dataAnalytics: true,
      profileVisibility: 'private',
    );
  }

  PrivacySettings copyWith({
    bool? shareLocation,
    bool? dataAnalytics,
    String? profileVisibility,
  }) {
    return PrivacySettings(
      shareLocation: shareLocation ?? this.shareLocation,
      dataAnalytics: dataAnalytics ?? this.dataAnalytics,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }
}

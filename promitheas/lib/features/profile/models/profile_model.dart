class ProfileModel {
  const ProfileModel({
    required this.userId,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.birthday = '',
    this.role = 'Customer',
    this.notificationsEnabled = false,
    this.notificationThreshold = 0.0,
  });

  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String birthday;
  final String role;
  final bool notificationsEnabled;
  final double notificationThreshold;

  // --- 1. DESEMPAQUETAR (De Supabase a Flutter) ---
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone']?.toString() ?? '', 
      birthday: json['birthday'] as String? ?? '',
      role: json['role'] as String? ?? 'Customer',
      notificationsEnabled: json['notification_enabled'] as bool? ?? false,
      notificationThreshold: (json['notification_threshold'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // --- 2. EMPAQUETAR (De Flutter a Supabase) ---
  // ¡ESTE ES EL MÉTODO QUE FALTABA!
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'birthday': birthday,
      'notification_enabled': notificationsEnabled,
      'notification_threshold': notificationThreshold,
      // No incluimos user_id ni email porque no queremos que se puedan editar
    };
  }

  // --- 3. CLONAR (Para Riverpod) ---
  ProfileModel copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? birthday,
    String? role,
    bool? notificationsEnabled,
    double? notificationThreshold,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      role: role ?? this.role,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationThreshold: notificationThreshold ?? this.notificationThreshold,
    );
  }
}
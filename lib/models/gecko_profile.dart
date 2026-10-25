class GeckoProfile {
  final String name;
  final String morph;
  final String sex;
  final DateTime birthDate;
  final String notes;
  final String avatarPath;

  GeckoProfile({
    required this.name,
    required this.morph,
    required this.sex,
    required this.birthDate,
    this.notes = '',
    this.avatarPath = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'morph': morph,
        'sex': sex,
        'birthDate': birthDate.toIso8601String(),
        'notes': notes,
        'avatarPath': avatarPath,
      };

  factory GeckoProfile.fromJson(Map<String, dynamic> json) {
    try {
      DateTime parsedBirthDate = DateTime.now();
      if (json['birthDate'] != null) {
        final parsed = DateTime.tryParse(json['birthDate'].toString());
        if (parsed != null) {
          parsedBirthDate = parsed;
        }
      }

      return GeckoProfile(
        name: json['name'] as String? ?? 'Мой Эублефар',
        morph: json['morph'] as String? ?? 'Normal',
        sex: json['sex'] as String? ?? 'Не определен',
        birthDate: parsedBirthDate,
        notes: json['notes'] as String? ?? '',
        avatarPath: json['avatarPath'] as String? ?? '',
      );
    } catch (_) {
      return GeckoProfile.defaultProfile();
    }
  }

  factory GeckoProfile.defaultProfile() {
    return GeckoProfile(
      name: 'Лимончик',
      morph: 'Tremper Albino',
      sex: 'Самец',
      birthDate: DateTime.now().subtract(const Duration(days: 365)),
      notes: 'Любит охотиться на сверчков в сумерках',
      avatarPath: '',
    );
  }

  GeckoProfile copyWith({
    String? name,
    String? morph,
    String? sex,
    DateTime? birthDate,
    String? notes,
    String? avatarPath,
  }) {
    return GeckoProfile(
      name: name ?? this.name,
      morph: morph ?? this.morph,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      notes: notes ?? this.notes,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}

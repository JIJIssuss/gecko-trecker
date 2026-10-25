enum LogType {
  feeding,   // Кормление
  shedding,  // Линька
  weight,    // Взвешивание
  health,    // Здоровье / Заметка
}

class LogEntry {
  final String id;
  final LogType type;
  final DateTime dateTime;
  final String title;
  final String details;
  final double? numericValue; // Вес или количество насекомых
  final String? tag;          // Добавки: Кальций D3, Витамины и т.д.

  LogEntry({
    required this.id,
    required this.type,
    required this.dateTime,
    required this.title,
    this.details = '',
    this.numericValue,
    this.tag,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'dateTime': dateTime.toIso8601String(),
        'title': title,
        'details': details,
        'numericValue': numericValue,
        'tag': tag,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
      final typeString = json['type'] as String? ?? '';
      final type = LogType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => LogType.health,
      );

      DateTime dt = DateTime.now();
      if (json['dateTime'] != null) {
        final parsed = DateTime.tryParse(json['dateTime'].toString());
        if (parsed != null) {
          dt = parsed;
        }
      }

      final title = json['title'] as String? ?? '';
      final details = json['details'] as String? ?? '';
      final numericValue = (json['numericValue'] as num?)?.toDouble();
      final tag = json['tag'] as String?;

      return LogEntry(
        id: id,
        type: type,
        dateTime: dt,
        title: title,
        details: details,
        numericValue: numericValue,
        tag: tag,
      );
    } catch (_) {
      return LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: LogType.health,
        dateTime: DateTime.now(),
        title: 'Запись',
        details: '',
      );
    }
  }
}

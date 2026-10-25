import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gecko_profile.dart';
import '../models/log_entry.dart';

class StorageService {
  static const String _keyLogs = 'gecko_logs';
  static const String _keyProfile = 'gecko_profile';

  static Future<List<LogEntry>> loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_keyLogs);
      if (rawJson == null || rawJson.isEmpty) {
        return [];
      }
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        return [];
      }

      final List<LogEntry> list = [];
      for (final item in decoded) {
        try {
          if (item is Map<String, dynamic>) {
            list.add(LogEntry.fromJson(item));
          } else if (item is Map) {
            list.add(LogEntry.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (_) {
          // Игнорируем поврежденный элемент, чтобы не падал весь список
        }
      }
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLogs(List<LogEntry> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(logs.map((e) => e.toJson()).toList());
      await prefs.setString(_keyLogs, encoded);
    } catch (_) {
      // Логгирование или обработка при необходимости
    }
  }

  static Future<GeckoProfile> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_keyProfile);
      if (rawJson == null || rawJson.isEmpty) {
        return GeckoProfile.defaultProfile();
      }
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return GeckoProfile.fromJson(decoded);
      } else if (decoded is Map) {
        return GeckoProfile.fromJson(Map<String, dynamic>.from(decoded));
      }
      return GeckoProfile.defaultProfile();
    } catch (_) {
      return GeckoProfile.defaultProfile();
    }
  }

  static Future<void> saveProfile(GeckoProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
    } catch (_) {
      // Логгирование или обработка
    }
  }
}

import 'package:flutter/material.dart';
import 'models/gecko_profile.dart';
import 'models/log_entry.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/weight_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/add_entry_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const GeckoTrackerApp());
}

class GeckoTrackerApp extends StatelessWidget {
  const GeckoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gecko Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationHolder(),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;
  bool _isLoading = true;

  GeckoProfile _profile = GeckoProfile.defaultProfile();
  List<LogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await StorageService.loadProfile();
    final logs = await StorageService.loadLogs();
    if (mounted) {
      setState(() {
        _profile = profile;
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  void _addLog(LogEntry entry) async {
    setState(() {
      _logs.insert(0, entry);
    });
    await StorageService.saveLogs(_logs);
  }

  void _deleteLog(String id) async {
    setState(() {
      _logs.removeWhere((e) => e.id == id);
    });
    await StorageService.saveLogs(_logs);
  }

  void _saveProfile(GeckoProfile updated) async {
    setState(() {
      _profile = updated;
    });
    await StorageService.saveProfile(updated);
  }

  void _openAddSheet({LogType? initialType, List<LogType>? allowedTypes}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEntrySheet(
        onAdd: _addLog,
        initialType: initialType,
        allowedTypes: allowedTypes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryPurple),
        ),
      );
    }

    final screens = [
      HomeScreen(
        profile: _profile,
        logs: _logs,
        onOpenAddSheet: (LogType? type) {
          _openAddSheet(initialType: type);
        },
      ),
      HistoryScreen(
        logs: _logs,
        onDelete: _deleteLog,
        onRestore: _addLog,
        onAddPressed: () {
          _openAddSheet(allowedTypes: [LogType.feeding, LogType.health]);
        },
      ),
      WeightScreen(
        logs: _logs,
        onAddWeight: () {
          _openAddSheet(initialType: LogType.weight);
        },
      ),
      ProfileScreen(
        profile: _profile,
        onSave: _saveProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          enableFeedback: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'История',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.scale_rounded),
              label: 'Вес',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets_rounded),
              label: 'Питомец',
            ),
          ],
        ),
      ),
    );
  }
}

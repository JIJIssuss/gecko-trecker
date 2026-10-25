import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gecko_profile.dart';
import '../models/log_entry.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final GeckoProfile profile;
  final List<LogEntry> logs;
  final void Function(LogType? type) onOpenAddSheet;

  static const List<String> _facts = [
    "У эублефаров есть подвижные веки, чем они отличаются от большинства других гекконов.",
    "В случае опасности эублефар может отбросить хвост (автотомия), и со временем он отрастет заново, но уже другой формы.",
    "В дикой природе обитают в засушливых каменистых регионах Афганистана, Пакистана и Северо-Западной Индии.",
    "У эублефаров нет липких подушечек на лапах, поэтому они не могут лазать по стеклу или потолку, как другие гекконы.",
    "Эублефары — сумеречные и ночные животные, в природе они выходят на охоту в темное время суток.",
    "Своё название «леопардовый геккон» они получили благодаря пятнистому окрасу, напоминающему шкуру леопарда.",
    "Эублефары обладают отличным слухом и могут слышать вибрации, даже когда спят.",
    "В среднем эублефары живут 15-20 лет, а иногда и дольше при правильном уходе.",
    "Хвост эублефара — это хранилище жира. По его толщине можно судить о запасах питательных веществ.",
    "В отличие от многих рептилий, эублефары откладывают яйца с мягкой, кожистой скорлупой, а не с твердой."
  ];

  const HomeScreen({
    super.key,
    required this.profile,
    required this.logs,
    required this.onOpenAddSheet,
  });

  @override
  Widget build(BuildContext context) {
    final lastFeeding = logs.cast<LogEntry?>().firstWhere(
          (e) => e?.type == LogType.feeding,
          orElse: () => null,
        );
    final lastShedding = logs.cast<LogEntry?>().firstWhere(
          (e) => e?.type == LogType.shedding,
          orElse: () => null,
        );
    final lastWeight = logs.cast<LogEntry?>().firstWhere(
          (e) => e?.type == LogType.weight,
          orElse: () => null,
        );

    final ageYears = DateTime.now().difference(profile.birthDate).inDays ~/ 365;
    final ageMonths = (DateTime.now().difference(profile.birthDate).inDays % 365) ~/ 30;
    final factOfTheDay = _facts[DateTime.now().day % 10];

    final bool hasValidAvatar =
        profile.avatarPath.isNotEmpty && File(profile.avatarPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gecko Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Карточка профиля
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryPurple.withOpacity(0.18),
                      backgroundImage:
                          hasValidAvatar ? FileImage(File(profile.avatarPath)) : null,
                      child: !hasValidAvatar
                          ? const Icon(Icons.pets_rounded,
                              size: 38, color: AppTheme.primaryPurple)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.morph} • ${profile.sex}',
                            style: const TextStyle(
                                color: AppTheme.accentViolet, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Возраст: $ageYears г. $ageMonths мес.',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Кликабельные карточки статусов
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.restaurant_rounded,
                    title: 'Кормление',
                    subtitle: lastFeeding != null
                        ? '${DateTime.now().difference(lastFeeding.dateTime).inDays} дн. назад'
                        : 'Нет данных',
                    color: Colors.amberAccent,
                    onTap: () => onOpenAddSheet(LogType.feeding),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.replay_rounded,
                    title: 'Линька',
                    subtitle: lastShedding != null
                        ? '${DateTime.now().difference(lastShedding.dateTime).inDays} дн. назад'
                        : 'Нет данных',
                    color: AppTheme.primaryPurple,
                    onTap: () => onOpenAddSheet(LogType.shedding),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.scale_rounded,
                    title: 'Вес',
                    subtitle: lastWeight != null && lastWeight.numericValue != null
                        ? '${lastWeight.numericValue!.toStringAsFixed(1)} г'
                        : '—',
                    color: Colors.tealAccent,
                    onTap: () => onOpenAddSheet(LogType.weight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Недавние события с кнопкой добавления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Недавние события',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: AppTheme.primaryPurple, size: 28),
                  tooltip: 'Добавить событие',
                  onPressed: () => onOpenAddSheet(null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.hourglass_empty_rounded,
                          size: 48, color: AppTheme.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'Записей пока нет',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Добавить первую'),
                        onPressed: () => onOpenAddSheet(null),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...logs.take(5).map((log) => _buildLogTile(log)),
            const SizedBox(height: 24),

            // Факт дня
            Card(
              color: AppTheme.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.science_rounded, color: Colors.amberAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Факт дня',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            factOfTheDay,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogTile(LogEntry log) {
    IconData icon;
    Color iconColor;

    switch (log.type) {
      case LogType.feeding:
        icon = Icons.restaurant_rounded;
        iconColor = Colors.amberAccent;
        break;
      case LogType.shedding:
        icon = Icons.replay_rounded;
        iconColor = AppTheme.primaryPurple;
        break;
      case LogType.weight:
        icon = Icons.scale_rounded;
        iconColor = Colors.tealAccent;
        break;
      case LogType.health:
        icon = Icons.favorite_rounded;
        iconColor = Colors.pinkAccent;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.tag != null && log.tag!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  log.tag!,
                  style: const TextStyle(color: AppTheme.accentViolet, fontSize: 12),
                ),
              ),
            Text(
              DateFormat('dd.MM.yyyy, HH:mm').format(log.dateTime),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

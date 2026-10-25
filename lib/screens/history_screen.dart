import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final List<LogEntry> logs;
  final void Function(String id) onDelete;
  final void Function(LogEntry entry)? onRestore;
  final VoidCallback onAddPressed;

  const HistoryScreen({
    super.key,
    required this.logs,
    required this.onDelete,
    this.onRestore,
    required this.onAddPressed,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  LogType? _filterType;

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _filterType == null
        ? widget.logs
        : widget.logs.where((e) => e.type == _filterType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('История записей'),
      ),
      body: Column(
        children: [
          // Фильтры
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _filterType == null,
                  onSelected: (_) => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Кормления'),
                  selected: _filterType == LogType.feeding,
                  onSelected: (_) => setState(() => _filterType = LogType.feeding),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Линьки'),
                  selected: _filterType == LogType.shedding,
                  onSelected: (_) => setState(() => _filterType = LogType.shedding),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Вес'),
                  selected: _filterType == LogType.weight,
                  onSelected: (_) => setState(() => _filterType = LogType.weight),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Заметки'),
                  selected: _filterType == LogType.health,
                  onSelected: (_) => setState(() => _filterType = LogType.health),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2E2740)),
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      'Ничего не найдено',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final item = filteredLogs[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                        ),
                        onDismissed: (_) {
                          final deletedItem = item;
                          widget.onDelete(deletedItem.id);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Удалено: ${deletedItem.title}'),
                              backgroundColor: AppTheme.surfaceLight,
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Отмена',
                                textColor: AppTheme.primaryPurple,
                                onPressed: () {
                                  widget.onRestore?.call(deletedItem);
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(item.title,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.details.isNotEmpty)
                                  Text(item.details,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary)),
                                if (item.tag != null && item.tag!.isNotEmpty)
                                  Text(item.tag!,
                                      style: const TextStyle(
                                          color: AppTheme.accentViolet,
                                          fontSize: 12)),
                                Text(
                                  DateFormat('dd.MM.yyyy, HH:mm')
                                      .format(item.dateTime),
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.white38),
                              onPressed: () {
                                final deletedItem = item;
                                widget.onDelete(deletedItem.id);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Удалено: ${deletedItem.title}'),
                                    backgroundColor: AppTheme.surfaceLight,
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      label: 'Отмена',
                                      textColor: AppTheme.primaryPurple,
                                      onPressed: () {
                                        widget.onRestore?.call(deletedItem);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddPressed,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

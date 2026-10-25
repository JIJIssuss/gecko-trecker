import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/log_entry.dart';
import '../theme/app_theme.dart';

class WeightScreen extends StatelessWidget {
  final List<LogEntry> logs;
  final VoidCallback onAddWeight;

  const WeightScreen({
    super.key,
    required this.logs,
    required this.onAddWeight,
  });

  @override
  Widget build(BuildContext context) {
    final weightLogs = logs
        .where((e) => e.type == LogType.weight && e.numericValue != null)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final currentWeight =
        weightLogs.isNotEmpty ? weightLogs.last.numericValue! : 0.0;
    final prevWeight = weightLogs.length > 1
        ? weightLogs[weightLogs.length - 2].numericValue!
        : currentWeight;
    final diff = currentWeight - prevWeight;

    final recentLogs = weightLogs.length > 10
        ? weightLogs.sublist(weightLogs.length - 10)
        : weightLogs;

    final List<FlSpot> spots = [];
    double minY = 1000;
    double maxY = 0;

    for (int i = 0; i < recentLogs.length; i++) {
      final weight = recentLogs[i].numericValue!;
      spots.add(FlSpot(i.toDouble(), weight));
      if (weight < minY) minY = weight;
      if (weight > maxY) maxY = weight;
    }

    if (spots.isEmpty) {
      minY = 0;
      maxY = 100;
    } else {
      minY = (minY - 5).clamp(0, double.infinity);
      maxY = maxY + 5;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Динамика веса')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Текущий вес
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Текущий вес',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      '${currentWeight.toStringAsFixed(1)} г',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (weightLogs.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            diff >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 18,
                            color: diff >= 0
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} г',
                            style: TextStyle(
                              color: diff >= 0
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // График веса
            if (spots.length > 1) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('График роста',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 24, right: 16, left: 8, bottom: 8),
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: AppTheme.surfaceLight,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}г',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: spots.length > 5
                                  ? (spots.length / 4).ceilToDouble()
                                  : 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < recentLogs.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('dd.MM')
                                          .format(recentLogs[index].dateTime),
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: AppTheme.primaryPurple,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryPurple.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Список взвешиваний
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('История взвешиваний',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (weightLogs.isNotEmpty)
                  Text('${weightLogs.length} записей',
                      style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            if (weightLogs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Нет записей о весе',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else
              ...weightLogs.reversed.map(
                (log) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF2E2740),
                      child: Icon(Icons.scale_rounded,
                          color: Colors.tealAccent, size: 20),
                    ),
                    title: Text('${log.numericValue!.toStringAsFixed(1)} г',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        DateFormat('dd.MM.yyyy, HH:mm').format(log.dateTime)),
                    trailing: log.details.isNotEmpty
                        ? Text(log.details,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12))
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddWeight,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

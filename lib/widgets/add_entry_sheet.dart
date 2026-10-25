import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../theme/app_theme.dart';

class AddEntrySheet extends StatefulWidget {
  final void Function(LogEntry entry) onAdd;
  final LogType? initialType;
  final List<LogType>? allowedTypes;

  const AddEntrySheet({
    super.key,
    required this.onAdd,
    this.initialType,
    this.allowedTypes,
  });

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  late LogType _selectedType;
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _countController = TextEditingController(text: '5');
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedFood = 'Сверчки домовые';
  String _selectedSupplement = 'Кальций с D3';
  String _sheddingQuality = 'Идеальная (без остатков)';

  final List<String> _foods = [
    'Сверчки домовые',
    'Сверчки банановые',
    'Тараканы туркменские',
    'Тараканы мраморные',
    'Мучной червь',
    'Бражник',
  ];

  final List<String> _supplements = [
    'Кальций с D3',
    'Чистый кальций (без D3)',
    'Мультивитамины',
    'Без добавок',
  ];

  final List<String> _sheddingOptions = [
    'Идеальная (без остатков)',
    'Остатки на пальчиках',
    'Остатки на кончике хвоста',
    'Сложная линька',
  ];

  List<LogType> get _availableTypes {
    if (widget.initialType != null) {
      return [widget.initialType!];
    }
    if (widget.allowedTypes != null && widget.allowedTypes!.isNotEmpty) {
      return widget.allowedTypes!;
    }
    return LogType.values;
  }

  bool get _showTypeSelector =>
      widget.initialType == null && _availableTypes.length > 1;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? _availableTypes.first;
  }

  @override
  void dispose() {
    _countController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    String title = '';
    String details = '';
    double? numVal;
    String? tag;

    switch (_selectedType) {
      case LogType.feeding:
        final count = int.tryParse(_countController.text) ?? 1;
        numVal = count.toDouble();
        title = '$_selectedFood ($count шт.)';
        tag = _selectedSupplement;
        details = _notesController.text.trim();
        break;
      case LogType.shedding:
        title = 'Линька: $_sheddingQuality';
        tag = _sheddingQuality.contains('Идеальная') ? 'Успешно' : 'Внимание';
        details = _notesController.text.trim();
        break;
      case LogType.weight:
        final w = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0;
        if (w <= 0) return;
        numVal = w;
        title = 'Вес: ${w.toStringAsFixed(1)} г';
        details = _notesController.text.trim();
        break;
      case LogType.health:
        title = _notesController.text.trim().isEmpty
            ? 'Общая заметка'
            : _notesController.text.trim();
        details = 'Проверка состояния';
        break;
    }

    final newEntry = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      dateTime: _selectedDate,
      title: title,
      details: details,
      numericValue: numVal,
      tag: tag,
    );

    widget.onAdd(newEntry);
    Navigator.of(context).pop();
  }

  String _sheetTitle() {
    if (widget.initialType != null) {
      switch (widget.initialType!) {
        case LogType.feeding:
          return 'Кормление';
        case LogType.shedding:
          return 'Линька';
        case LogType.weight:
          return 'Взвешивание';
        case LogType.health:
          return 'Заметка';
      }
    }
    return 'Новая запись';
  }

  IconData _typeIcon(LogType type) {
    switch (type) {
      case LogType.feeding:
        return Icons.restaurant_rounded;
      case LogType.shedding:
        return Icons.replay_rounded;
      case LogType.weight:
        return Icons.scale_rounded;
      case LogType.health:
        return Icons.favorite_rounded;
    }
  }

  String _typeLabel(LogType type) {
    switch (type) {
      case LogType.feeding:
        return 'Еда';
      case LogType.shedding:
        return 'Линька';
      case LogType.weight:
        return 'Вес';
      case LogType.health:
        return 'Инфо';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _sheetTitle(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_showTypeSelector) ...[
              SegmentedButton<LogType>(
                segments: _availableTypes.map((type) {
                  return ButtonSegment<LogType>(
                    value: type,
                    icon: Icon(_typeIcon(type)),
                    label: Text(_typeLabel(type)),
                  );
                }).toList(),
                selected: {_selectedType},
                onSelectionChanged: (set) => setState(() => _selectedType = set.first),
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_selectedType == LogType.feeding) ...[
              DropdownButtonFormField<String>(
                value: _selectedFood,
                decoration: const InputDecoration(labelText: 'Кормовой объект'),
                items: _foods.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) => setState(() => _selectedFood = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Количество (шт.)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSupplement,
                      decoration: const InputDecoration(labelText: 'Витамины / Кальций'),
                      items: _supplements.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedSupplement = v!),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedType == LogType.shedding) ...[
              DropdownButtonFormField<String>(
                value: _sheddingQuality,
                decoration: const InputDecoration(labelText: 'Качество линьки'),
                items: _sheddingOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _sheddingQuality = v!),
              ),
            ] else if (_selectedType == LogType.weight) ...[
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Вес эублефара (граммы)',
                  prefixIcon: Icon(Icons.scale_rounded, color: AppTheme.primaryPurple),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Заметки / Наблюдения',
                prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.primaryPurple),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryPurple),
              title: Text('Дата: ${DateFormat('dd.MM.yyyy, HH:mm').format(_selectedDate)}'),
              trailing: TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
                child: const Text('Изменить'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Сохранить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

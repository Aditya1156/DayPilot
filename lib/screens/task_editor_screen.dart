import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daypilot/models/task.dart';
import 'package:daypilot/providers/app_providers.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key});

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskCategory _category = TaskCategory.personal;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 1));
  String? _rrule;
  int _reminderOffsetMinutes = 10;
  int _estimatedDurationMinutes = 60;
  String? _taskId;

  @override
  void initState() {
    super.initState();
    // Avoid using BuildContext across async gaps inside initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localRef = ref;
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments;
      if (args is String) {
        final id = args;
        final tasks = localRef.read(tasksProvider);
        final matches = tasks.where((t) => t.id == id);
        if (matches.isNotEmpty) {
          final match = matches.first;
          setState(() {
            _taskId = match.id;
            _titleCtrl.text = match.title;
            _descCtrl.text = match.description ?? '';
            _category = match.category;
            _start = match.startTime;
            _end = match.endTime;
            _rrule = match.rrule;
            _reminderOffsetMinutes = match.reminderOffsetMinutes;
            _estimatedDurationMinutes = match.estimatedDurationMinutes;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final localContext = context;
    final dt = await showDatePicker(
      context: localContext,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dt == null) return;
    final t = await showTimePicker(context: localContext, initialTime: TimeOfDay.fromDateTime(_start));
    if (t == null) return;
    setState(() {
      _start = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute);
      if (_end.isBefore(_start)) _end = _start.add(const Duration(hours: 1));
    });
  }

  Future<void> _pickEnd() async {
    final localContext = context;
    final dt = await showDatePicker(
      context: localContext,
      initialDate: _end,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dt == null) return;
    final t = await showTimePicker(context: localContext, initialTime: TimeOfDay.fromDateTime(_end));
    if (t == null) return;
    setState(() {
      _end = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final id = _taskId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final task = Task(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      category: _category,
      startTime: _start,
      endTime: _end,
      status: TaskStatus.pending,
      rrule: _rrule,
      reminderOffsetMinutes: _reminderOffsetMinutes,
      estimatedDurationMinutes: _estimatedDurationMinutes,
    );

    if (_taskId == null) {
      ref.read(tasksProvider.notifier).addTask(task);
    } else {
      ref.read(tasksProvider.notifier).updateTask(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_taskId == null ? 'New Task' : 'Edit Task'),
        actions: [
          if (_taskId != null)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                ref.read(tasksProvider.notifier).deleteTask(_taskId!);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              // Reminder offset
              Row(
                children: [
                  const Expanded(child: Text('Reminder')),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _reminderOffsetMinutes,
                    items: const [0, 5, 10, 15, 30, 60].map((m) => DropdownMenuItem(value: m, child: Text(m == 0 ? 'At time' : '\${m}m before'))).toList(),
                    onChanged: (v) => setState(() { _reminderOffsetMinutes = v ?? 10; }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Text('Estimated duration')),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _estimatedDurationMinutes,
                    items: const [15, 30, 45, 60, 90, 120].map((m) => DropdownMenuItem(value: m, child: Text('\${m}m'))).toList(),
                    onChanged: (v) => setState(() { _estimatedDurationMinutes = v ?? 60; }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Recurrence selector
              DropdownButtonFormField<String?>(
                value: _rrule,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Does not repeat')),
                  DropdownMenuItem(value: 'FREQ=DAILY;INTERVAL=1', child: Text('Daily')),
                  DropdownMenuItem(value: 'FREQ=WEEKLY;INTERVAL=1', child: Text('Weekly')),
                  DropdownMenuItem(value: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR', child: Text('Weekdays (Mon-Fri)')),
                ],
                onChanged: (v) => setState(() { _rrule = v; }),
                decoration: const InputDecoration(labelText: 'Repeat'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskCategory>(
                value: _category,
                items: TaskCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.toString().split('.').last))).toList(),
                onChanged: (v) => setState(() { _category = v ?? TaskCategory.personal; }),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _pickStart, child: Text('Start: ${_start.toLocal()}'.split('.')[0]))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: _pickEnd, child: Text('End: ${_end.toLocal()}'.split('.')[0]))),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save Task')),
            ],
          ),
        ),
      ),
    );
  }
}

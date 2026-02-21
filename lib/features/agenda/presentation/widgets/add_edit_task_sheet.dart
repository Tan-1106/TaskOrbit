import 'package:flutter/material.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';

class AddEditTaskSheet extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final DateTime initialDate;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;
  final bool initialIsAllDay;
  final String? initialCategoryId;
  final bool isEditing;
  final List<Category> categories;

  const AddEditTaskSheet({
    super.key,
    this.initialTitle,
    this.initialDescription,
    required this.initialDate,
    this.initialStartTime,
    this.initialEndTime,
    this.initialIsAllDay = false,
    this.initialCategoryId,
    this.isEditing = false,
    this.categories = const [],
  });

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  DateTime? _startTime;
  DateTime? _endTime;
  late bool _isAllDay;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedDate = widget.initialDate;
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _isAllDay = widget.initialIsAllDay;
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime != null
            ? TimeOfDay.fromDateTime(_startTime!)
            : TimeOfDay.now())
        : (_endTime != null
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        final dt = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _startTime = dt;
        } else {
          _endTime = dt;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.isEditing ? l10n.taskFormEditTask : l10n.taskFormNewTask,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.taskFormTitleLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.taskFormTitleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.taskFormDescriptionLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              if (widget.categories.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.taskFormCategoryLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.label),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.taskFormNoCategoryOption),
                    ),
                    ...widget.categories.map((cat) {
                      return DropdownMenuItem<String?>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: cat.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Date picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                subtitle: Text(l10n.taskFormDateLabel),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
              const SizedBox(height: 12),

              // All Day Switch
              SwitchListTile(
                title: Text(l10n.taskFormAllDayLabel),
                value: _isAllDay,
                onChanged: (value) => setState(() => _isAllDay = value),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
              const SizedBox(height: 12),

              // Time pickers
              if (!_isAllDay) ...[
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          _startTime != null
                              ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                              : l10n.taskFormStartTimeLabel,
                        ),
                        onTap: () => _pickTime(isStart: true),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: theme.colorScheme.outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          _endTime != null
                              ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                              : l10n.taskFormEndTimeLabel,
                        ),
                        onTap: () => _pickTime(isStart: false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                              color: theme.colorScheme.outline),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Submit button
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (!_isAllDay &&
                          _startTime != null &&
                          _endTime != null &&
                          _endTime!.isBefore(_startTime!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(l10n.taskFormEndBeforeStartError)),
                        );
                        return;
                      }

                      Navigator.of(context).pop({
                        'title': _titleController.text.trim(),
                        'description':
                            _descriptionController.text.trim(),
                        'date': _selectedDate,
                        'startTime': _isAllDay ? null : _startTime,
                        'endTime': _isAllDay ? null : _endTime,
                        'isAllDay': _isAllDay,
                        'categoryId': _selectedCategoryId,
                      });
                    }
                  },
                  child: Text(widget.isEditing
                      ? l10n.taskFormSaveButton
                      : l10n.taskFormCreateButton),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

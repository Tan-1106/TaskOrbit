import 'package:flutter/material.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class FilterDialog extends StatefulWidget {
  final TaskFilter? currentFilter;
  final List<Category> categories;

  const FilterDialog({
    super.key,
    this.currentFilter,
    this.categories = const [],
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _keywordController;
  bool? _isCompleted;
  String? _categoryId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(text: widget.currentFilter?.keyword);
    _isCompleted = widget.currentFilter?.isCompleted;
    _categoryId = widget.currentFilter?.categoryId;
    _fromDate = widget.currentFilter?.fromDate;
    _toDate = widget.currentFilter?.toDate;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.filterTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _keywordController,
              decoration: InputDecoration(
                labelText: l10n.filterKeywordLabel,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Text(l10n.filterStatusLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<bool?>(
              segments: [
                ButtonSegment(value: null, label: Text(l10n.filterStatusAll)),
                ButtonSegment(value: false, label: Text(l10n.filterStatusPending)),
                ButtonSegment(value: true, label: Text(l10n.filterStatusDone)),
              ],
              selected: {_isCompleted},
              onSelectionChanged: (values) {
                setState(() => _isCompleted = values.first);
              },
            ),
            const SizedBox(height: 16),

            if (widget.categories.isNotEmpty) ...[
              Text(l10n.filterCategoryLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.filterAllCategories),
                  ),
                  ...widget.categories.map((cat) {
                    return DropdownMenuItem<String?>(
                      value: cat.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
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
                  setState(() => _categoryId = value);
                },
              ),
              const SizedBox(height: 16),
            ],

            Text(l10n.filterDateRangeLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _fromDate != null ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}' : l10n.filterFromDate,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _fromDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _toDate != null ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}' : l10n.filterToDate,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _toDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _toDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.filterCancelButton),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(const TaskFilter());
          },
          child: Text(l10n.filterClearButton),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              TaskFilter(
                keyword: _keywordController.text.trim().isNotEmpty ? _keywordController.text.trim() : null,
                isCompleted: _isCompleted,
                categoryId: _categoryId,
                fromDate: _fromDate,
                toDate: _toDate,
              ),
            );
          },
          child: Text(l10n.filterApplyButton),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class FilterDialog extends StatefulWidget {
  final List<Category> categories;

  const FilterDialog({
    super.key,
    this.categories = const [],
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _keywordController;
  bool? _isCompleted;
  String? _categoryId;
  TaskFilter _currentFilter = const TaskFilter();

  @override
  void initState() {
    super.initState();
    _currentFilter = context.read<AgendaBloc>().currentFilter;
    _keywordController = TextEditingController(text: _currentFilter.keyword ?? '');
    _isCompleted = _currentFilter.isCompleted;
    _categoryId = _currentFilter.categoryId;
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
        child: SizedBox(
          width: double.maxFinite,
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
              Text(
                l10n.filterStatusLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<bool?>(
                isExpanded: true,
                initialValue: _isCompleted,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<bool?>(
                    value: null,
                    child: Text(l10n.filterStatusAll),
                  ),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text(l10n.filterStatusPending),
                  ),
                  DropdownMenuItem<bool?>(
                    value: true,
                    child: Text(l10n.filterStatusDone),
                  ),
                ],
                onChanged: (value) => setState(() => _isCompleted = value),
              ),
              if (widget.categories.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.filterCategoryLabel,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
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
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
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
            final newFilter = TaskFilter(
              keyword: _keywordController.text.trim().isEmpty ? null : _keywordController.text.trim(),
              isCompleted: _isCompleted,
              categoryId: _categoryId,
            );
            context.pop(newFilter);
          },
          child: Text(l10n.filterApplyButton),
        ),
      ],
    );
  }
}

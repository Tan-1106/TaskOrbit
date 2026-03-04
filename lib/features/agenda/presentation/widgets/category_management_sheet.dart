import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_state.dart';

class CategoryManagementSheet extends StatefulWidget {
  const CategoryManagementSheet({super.key});

  @override
  State<CategoryManagementSheet> createState() => _CategoryManagementSheetState();
}

class _CategoryManagementSheetState extends State<CategoryManagementSheet> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  static const _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            l10n.categoryManageTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Existing categories
          BlocBuilder<AgendaBloc, AgendaState>(
            builder: (context, state) {
              if (state.categories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.categoryNoCategories,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final cat = state.categories[index];
                    return _CategoryTile(
                      category: cat,
                      onDelete: () => _confirmDelete(context, cat, l10n),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),

          // Add new category
          Text(
            l10n.categoryNewTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.categoryNameLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.label),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions.map((color) {
              final isSelected = _selectedColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: _contrastColor(color),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 48,
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.categoryAddButton),
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.categoryNameRequired)),
                  );
                  return;
                }
                context.read<AgendaBloc>().add(
                  AgendaCreateCategory(name: name, color: _selectedColor),
                );
                _nameController.clear();
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Category category,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.categoryDeleteTitle),
        content: Text(l10n.categoryDeleteContent(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancelButton),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AgendaBloc>().add(
                AgendaDeleteCategory(categoryId: category.id),
              );
            },
            child: Text(l10n.dialogDeleteButton),
          ),
        ],
      ),
    );
  }

  Color _contrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black;
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color,
        radius: 14,
      ),
      title: Text(category.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
      ),
      dense: true,
    );
  }
}

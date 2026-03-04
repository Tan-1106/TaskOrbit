import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class PresetFormSheet extends StatefulWidget {
  final PomodoroPreset? existingPreset;

  const PresetFormSheet({super.key, this.existingPreset});

  @override
  State<PresetFormSheet> createState() => _PresetFormSheetState();
}

class _PresetFormSheetState extends State<PresetFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  static const _focusOptions = [15, 25, 45, 60];
  static const _shortBreakOptions = [5, 10, 15];
  static const _longBreakOptions = [15, 20, 30];
  static const _cyclesOptions = [2, 3, 4, 6];

  late int? _focusSelected; // null = "Other"
  late int? _shortSelected;
  late int? _longSelected;
  late int? _cyclesSelected;

  final _focusCustomCtrl = TextEditingController();
  final _shortCustomCtrl = TextEditingController();
  final _longCustomCtrl = TextEditingController();
  final _cyclesCustomCtrl = TextEditingController();

  bool get _isEdit => widget.existingPreset != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPreset;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');

    _focusSelected = _optionOrNull(_focusOptions, p?.focusMinutes ?? 25);
    _shortSelected = _optionOrNull(
      _shortBreakOptions,
      p?.shortBreakMinutes ?? 5,
    );
    _longSelected = _optionOrNull(_longBreakOptions, p?.longBreakMinutes ?? 15);
    _cyclesSelected = _optionOrNull(
      _cyclesOptions,
      p?.cyclesBeforeLongBreak ?? 4,
    );

    if (_focusSelected == null) {
      _focusCustomCtrl.text = '${p?.focusMinutes ?? ''}';
    }
    if (_shortSelected == null) {
      _shortCustomCtrl.text = '${p?.shortBreakMinutes ?? ''}';
    }
    if (_longSelected == null) {
      _longCustomCtrl.text = '${p?.longBreakMinutes ?? ''}';
    }
    if (_cyclesSelected == null) {
      _cyclesCustomCtrl.text = '${p?.cyclesBeforeLongBreak ?? ''}';
    }
  }

  int? _optionOrNull(List<int> options, int value) => options.contains(value) ? value : null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _focusCustomCtrl.dispose();
    _shortCustomCtrl.dispose();
    _longCustomCtrl.dispose();
    _cyclesCustomCtrl.dispose();
    super.dispose();
  }

  int? _resolveValue(int? selected, TextEditingController custom) {
    if (selected != null) return selected;
    return int.tryParse(custom.text.trim());
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final focus = _resolveValue(_focusSelected, _focusCustomCtrl);
    final shortB = _resolveValue(_shortSelected, _shortCustomCtrl);
    final longB = _resolveValue(_longSelected, _longCustomCtrl);
    final cycles = _resolveValue(_cyclesSelected, _cyclesCustomCtrl);

    if (focus == null || shortB == null || longB == null || cycles == null) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final preset = PomodoroPreset(
      id: widget.existingPreset?.id ?? const Uuid().v4(),
      userId: userId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      focusMinutes: focus,
      shortBreakMinutes: shortB,
      longBreakMinutes: longB,
      cyclesBeforeLongBreak: cycles,
    );

    context.read<PomodoroBloc>().add(PomodoroSavePreset(preset));
    Navigator.of(context).pop();
  }

  void _delete(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pomodoroDeletePresetTitle),
        content: Text(
          l10n.pomodoroDeletePresetContent(widget.existingPreset!.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<PomodoroBloc>().add(
                PomodoroDeletePreset(widget.existingPreset!.id),
              );
              Navigator.of(context).pop();
            },
            child: Text(l10n.dialogDeleteButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    _isEdit ? l10n.pomodoroPresetFormEdit : l10n.pomodoroPresetFormNew,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isEdit)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: l10n.pomodoroPresetDeleteButton,
                      onPressed: () => _delete(l10n),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.pomodoroPresetNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.pomodoroPresetNameRequired : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.pomodoroPresetDescLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              _RadioSection(
                label: l10n.pomodoroPresetFocusLabel,
                options: _focusOptions,
                selected: _focusSelected,
                customController: _focusCustomCtrl,
                l10n: l10n,
                onChanged: (v) => setState(() => _focusSelected = v),
              ),
              const SizedBox(height: 16),
              _RadioSection(
                label: l10n.pomodoroPresetShortBreakLabel,
                options: _shortBreakOptions,
                selected: _shortSelected,
                customController: _shortCustomCtrl,
                l10n: l10n,
                onChanged: (v) => setState(() => _shortSelected = v),
              ),
              const SizedBox(height: 16),
              _RadioSection(
                label: l10n.pomodoroPresetLongBreakLabel,
                options: _longBreakOptions,
                selected: _longSelected,
                customController: _longCustomCtrl,
                l10n: l10n,
                onChanged: (v) => setState(() => _longSelected = v),
              ),
              const SizedBox(height: 16),
              _RadioSection(
                label: l10n.pomodoroPresetCyclesLabel,
                options: _cyclesOptions,
                selected: _cyclesSelected,
                customController: _cyclesCustomCtrl,
                l10n: l10n,
                onChanged: (v) => setState(() => _cyclesSelected = v),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(l10n.pomodoroPresetSaveButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioSection extends StatelessWidget {
  final String label;
  final List<int> options;
  final int? selected; // null = "Other"
  final TextEditingController customController;
  final AppLocalizations l10n;
  final ValueChanged<int?> onChanged;

  const _RadioSection({
    required this.label,
    required this.options,
    required this.selected,
    required this.customController,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOther = selected == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: [
            ...options.map(
              (opt) => ChoiceChip(
                label: Text('$opt'),
                selected: selected == opt,
                onSelected: (_) => onChanged(opt),
              ),
            ),
            ChoiceChip(
              label: Text(l10n.pomodoroPresetOtherOption),
              selected: isOther,
              onSelected: (_) => onChanged(null),
            ),
          ],
        ),
        if (isOther) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: customController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: l10n.pomodoroPresetCustomValueHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l10n.pomodoroPresetCustomValueRequired;
              }
              final n = int.tryParse(v.trim());
              if (n == null || n <= 0) {
                return l10n.pomodoroPresetCustomValueInvalid;
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

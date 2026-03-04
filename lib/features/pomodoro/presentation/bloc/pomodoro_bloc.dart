import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_phase.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/get_presets.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/save_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/delete_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/sync_presets.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_state.dart';

// Internal tick event — lives in the same file as the Bloc for privacy
class _PomodoroTick extends PomodoroEvent {
  const _PomodoroTick();
}

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final GetPresets getPresets;
  final SavePreset savePreset;
  final DeletePreset deletePreset;
  final SyncPresets syncPresets;
  final FirebaseAuth firebaseAuth;

  Timer? _timer;

  PomodoroBloc({
    required this.getPresets,
    required this.savePreset,
    required this.deletePreset,
    required this.syncPresets,
    required this.firebaseAuth,
  }) : super(PomodoroState.initial()) {
    on<PomodoroLoad>(_onLoad);
    on<PomodoroSelectPreset>(_onSelectPreset);
    on<PomodoroStartPause>(_onStartPause);
    on<PomodoroResetCycle>(_onResetCycle);
    on<PomodoroResetAll>(_onResetAll);
    on<_PomodoroTick>(_onTick);
    on<PomodoroSavePreset>(_onSavePreset);
    on<PomodoroDeletePreset>(_onDeletePreset);
    on<PomodoroToggleRepeat>(_onToggleRepeat);
  }

  String? get _userId => firebaseAuth.currentUser?.uid;

  Future<void> _onLoad(
    PomodoroLoad event,
    Emitter<PomodoroState> emit,
  ) async {
    syncPresets(event.userId);

    final result = await getPresets(event.userId);
    result.fold(
      (_) {}, // silently ignore load errors
      (presets) {
        final allPresets = [classicPreset, ...presets];
        emit(state.copyWith(presets: allPresets));
      },
    );
  }

  void _onSelectPreset(
    PomodoroSelectPreset event,
    Emitter<PomodoroState> emit,
  ) {
    _cancelTimer();
    emit(
      PomodoroState(
        presets: state.presets,
        selectedPreset: event.preset,
        phase: PomodoroPhase.focus,
        cycleIndex: 0,
        secondsRemaining: event.preset.focusMinutes * 60,
        isRunning: false,
        isFinished: false,
        isRepeat: state.isRepeat,
      ),
    );
  }

  void _onStartPause(
    PomodoroStartPause event,
    Emitter<PomodoroState> emit,
  ) {
    if (state.isFinished) return;

    if (state.isRunning) {
      _cancelTimer();
      emit(state.copyWith(isRunning: false));
    } else {
      _startTimer();
      emit(state.copyWith(isRunning: true));
    }
  }

  void _onResetCycle(
    PomodoroResetCycle event,
    Emitter<PomodoroState> emit,
  ) {
    _cancelTimer();
    emit(
      state.copyWith(
        secondsRemaining: _secondsForPhase(state.phase, state.selectedPreset),
        isRunning: false,
        isFinished: false,
      ),
    );
  }

  void _onResetAll(
    PomodoroResetAll event,
    Emitter<PomodoroState> emit,
  ) {
    _cancelTimer();
    emit(
      PomodoroState(
        presets: state.presets,
        selectedPreset: state.selectedPreset,
        phase: PomodoroPhase.focus,
        cycleIndex: 0,
        secondsRemaining: state.selectedPreset.focusMinutes * 60,
        isRunning: false,
        isFinished: false,
        isRepeat: state.isRepeat,
      ),
    );
  }

  void _onTick(
    _PomodoroTick event,
    Emitter<PomodoroState> emit,
  ) {
    if (state.secondsRemaining > 0) {
      emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      return;
    }
    _cancelTimer();
    final next = _nextPhase(
      state.phase,
      state.cycleIndex,
      state.selectedPreset.cyclesBeforeLongBreak,
    );
    if (state.phase == PomodoroPhase.longBreak) {
      if (state.isRepeat) {
        emit(
          PomodoroState(
            presets: state.presets,
            selectedPreset: state.selectedPreset,
            phase: PomodoroPhase.focus,
            cycleIndex: 0,
            secondsRemaining: state.selectedPreset.focusMinutes * 60,
            isRunning: true,
            isFinished: false,
            isRepeat: state.isRepeat,
          ),
        );
        _startTimer();
      } else {
        emit(
          PomodoroState(
            presets: state.presets,
            selectedPreset: state.selectedPreset,
            phase: PomodoroPhase.focus,
            cycleIndex: 0,
            secondsRemaining: state.selectedPreset.focusMinutes * 60,
            isRunning: false,
            isFinished: true,
            isRepeat: state.isRepeat,
          ),
        );
      }
      return;
    }

    emit(
      PomodoroState(
        presets: state.presets,
        selectedPreset: state.selectedPreset,
        phase: next.phase,
        cycleIndex: next.cycleIndex,
        secondsRemaining: _secondsForPhase(next.phase, state.selectedPreset),
        isRunning: true,
        isFinished: false,
        isRepeat: state.isRepeat,
      ),
    );
    _startTimer();
  }

  Future<void> _onSavePreset(
    PomodoroSavePreset event,
    Emitter<PomodoroState> emit,
  ) async {
    final result = await savePreset(event.preset);
    if (result.isLeft()) return;

    final uid = _userId;
    if (uid == null) return;

    final presetsResult = await getPresets(uid);
    if (presetsResult.isLeft()) return;

    final presets = presetsResult.getOrElse((_) => []);
    emit(state.copyWith(presets: [classicPreset, ...presets]));
  }

  Future<void> _onDeletePreset(
    PomodoroDeletePreset event,
    Emitter<PomodoroState> emit,
  ) async {
    final uid = _userId;
    if (uid == null) return;

    final result = await deletePreset(uid, event.presetId);
    if (result.isLeft()) return;
    final wasSelected = state.selectedPreset.id == event.presetId;
    if (wasSelected) _cancelTimer();

    final presetsResult = await getPresets(uid);
    if (presetsResult.isLeft()) return;

    final presets = presetsResult.getOrElse((_) => []);
    final allPresets = [classicPreset, ...presets];

    if (wasSelected) {
      emit(
        PomodoroState(
          presets: allPresets,
          selectedPreset: classicPreset,
          phase: PomodoroPhase.focus,
          cycleIndex: 0,
          secondsRemaining: classicPreset.focusMinutes * 60,
          isRunning: false,
          isFinished: false,
          isRepeat: state.isRepeat,
        ),
      );
    } else {
      emit(state.copyWith(presets: allPresets));
    }
  }

  void _onToggleRepeat(
    PomodoroToggleRepeat event,
    Emitter<PomodoroState> emit,
  ) {
    emit(state.copyWith(isRepeat: !state.isRepeat));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const _PomodoroTick());
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  int _secondsForPhase(PomodoroPhase phase, PomodoroPreset preset) {
    return switch (phase) {
      PomodoroPhase.focus => preset.focusMinutes * 60,
      PomodoroPhase.shortBreak => preset.shortBreakMinutes * 60,
      PomodoroPhase.longBreak => preset.longBreakMinutes * 60,
    };
  }

  ({PomodoroPhase phase, int cycleIndex}) _nextPhase(
    PomodoroPhase current,
    int cycleIndex,
    int cyclesBeforeLongBreak,
  ) {
    return switch (current) {
      PomodoroPhase.focus =>
        (cycleIndex + 1) < cyclesBeforeLongBreak
            ? (phase: PomodoroPhase.shortBreak, cycleIndex: cycleIndex + 1)
            : (phase: PomodoroPhase.longBreak, cycleIndex: 0),
      PomodoroPhase.shortBreak => (
        phase: PomodoroPhase.focus,
        cycleIndex: cycleIndex,
      ),
      PomodoroPhase.longBreak => (phase: PomodoroPhase.focus, cycleIndex: 0),
    };
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}

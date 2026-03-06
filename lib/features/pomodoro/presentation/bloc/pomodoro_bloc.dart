import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/core/services/notification_service.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_phase.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/get_presets.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/save_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/delete_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/sync_presets.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

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
  final NotificationService notificationService;
  final ConnectivityService connectivityService;
  final SharedPreferences sharedPreferences;
  final LocaleNotifier localeNotifier;

  Timer? _timer;
  StreamSubscription? _authSubscription;
  StreamSubscription? _connectivitySubscription;
  DateTime? _phaseEndTime;

  // ── SharedPreferences keys for crash/kill recovery ──
  static const _kIsRunning = 'pomodoro_is_running';
  static const _kPhaseEndTime = 'pomodoro_phase_end_ms';
  static const _kPhase = 'pomodoro_phase';
  static const _kCycleIndex = 'pomodoro_cycle_index';
  static const _kIsRepeat = 'pomodoro_is_repeat';
  static const _kPresetId = 'pomodoro_preset_id';

  PomodoroBloc({
    required this.getPresets,
    required this.savePreset,
    required this.deletePreset,
    required this.syncPresets,
    required this.firebaseAuth,
    required this.notificationService,
    required this.connectivityService,
    required this.sharedPreferences,
    required this.localeNotifier,
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
    on<PomodoroAppPaused>(_onAppPaused);
    on<PomodoroAppResumed>(_onAppResumed);

    _authSubscription = firebaseAuth.authStateChanges().listen((user) {
      if (user != null && user.emailVerified) {
        add(PomodoroLoad(user.uid));
      }
    });

    _connectivitySubscription = connectivityService.onConnectivityChanged
        .listen((isConnected) {
          if (isConnected) {
            final uid = firebaseAuth.currentUser?.uid;
            if (uid != null) {
              add(PomodoroLoad(uid));
            }
          }
        });
  }

  String? get _userId => firebaseAuth.currentUser?.uid;

  Future<void> _onLoad(
    PomodoroLoad event,
    Emitter<PomodoroState> emit,
  ) async {
    await syncPresets(event.userId);

    final result = await getPresets(event.userId);
    result.fold(
      (_) {},
      (presets) {
        final allPresets = [classicPreset, ...presets];
        emit(state.copyWith(presets: allPresets));
        _tryRestoreSession(allPresets, emit);
      },
    );
  }

  /// Attempt to restore a timer session from SharedPreferences.
  void _tryRestoreSession(
    List<PomodoroPreset> presets,
    Emitter<PomodoroState> emit,
  ) {
    final wasRunning = sharedPreferences.getBool(_kIsRunning) ?? false;
    if (!wasRunning) return;

    final endMs = sharedPreferences.getInt(_kPhaseEndTime);
    if (endMs == null) return;

    final savedPhaseEndTime = DateTime.fromMillisecondsSinceEpoch(endMs);
    final phaseIndex = sharedPreferences.getInt(_kPhase) ?? 0;
    final cycleIndex = sharedPreferences.getInt(_kCycleIndex) ?? 0;
    final isRepeat = sharedPreferences.getBool(_kIsRepeat) ?? false;
    final presetId = sharedPreferences.getString(_kPresetId) ?? 'default';

    final preset = presets.firstWhere(
      (p) => p.id == presetId,
      orElse: () => classicPreset,
    );

    final phase = PomodoroPhase.values[phaseIndex.clamp(0, 2)];

    // Fast-forward through any phases that elapsed while the app was dead
    _phaseEndTime = savedPhaseEndTime;
    var currentPhase = phase;
    var currentCycle = cycleIndex;

    while (_phaseEndTime!.isBefore(DateTime.now())) {
      // This phase already finished
      if (currentPhase == PomodoroPhase.longBreak) {
        if (isRepeat) {
          currentPhase = PomodoroPhase.focus;
          currentCycle = 0;
          _phaseEndTime = _phaseEndTime!.add(
            Duration(seconds: _secondsForPhase(currentPhase, preset)),
          );
        } else {
          // Session is done
          _clearPersistedState();
          emit(
            PomodoroState(
              presets: presets,
              selectedPreset: preset,
              phase: PomodoroPhase.focus,
              cycleIndex: 0,
              secondsRemaining: preset.focusMinutes * 60,
              isRunning: false,
              isFinished: true,
              isRepeat: isRepeat,
            ),
          );
          return;
        }
      } else {
        final next = _nextPhase(currentPhase, currentCycle, preset.cyclesBeforeLongBreak);
        currentPhase = next.phase;
        currentCycle = next.cycleIndex;
        _phaseEndTime = _phaseEndTime!.add(
          Duration(seconds: _secondsForPhase(currentPhase, preset)),
        );
      }
    }

    final remaining = _phaseEndTime!.difference(DateTime.now()).inSeconds.clamp(0, 99999);

    emit(
      PomodoroState(
        presets: presets,
        selectedPreset: preset,
        phase: currentPhase,
        cycleIndex: currentCycle,
        secondsRemaining: remaining,
        isRunning: true,
        isFinished: false,
        isRepeat: isRepeat,
      ),
    );

    _startTimer();
  }

  void _onSelectPreset(
    PomodoroSelectPreset event,
    Emitter<PomodoroState> emit,
  ) {
    _cancelTimer();
    _clearPersistedState();
    notificationService.cancelPomodoroNotifications();
    _phaseEndTime = null;

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
      notificationService.cancelPomodoroNotifications();
      _phaseEndTime = null;
      _clearPersistedState();
      emit(state.copyWith(isRunning: false));
    } else {
      _phaseEndTime = DateTime.now().add(
        Duration(seconds: state.secondsRemaining),
      );
      _persistState();
      _startTimer();
      emit(state.copyWith(isRunning: true));
    }
  }

  void _onResetCycle(
    PomodoroResetCycle event,
    Emitter<PomodoroState> emit,
  ) {
    _cancelTimer();
    _phaseEndTime = null;
    _clearPersistedState();
    notificationService.cancelPomodoroNotifications();
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
    _phaseEndTime = null;
    _clearPersistedState();
    notificationService.cancelPomodoroNotifications();
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
    if (_phaseEndTime == null) return;

    final remaining = _phaseEndTime!.difference(DateTime.now()).inSeconds;

    if (remaining > 0) {
      emit(state.copyWith(secondsRemaining: remaining));
      return;
    }

    // Phase ended — advance
    _cancelTimer();
    _advancePhase(emit);
  }

  /// Advance to the next phase (called when seconds hit 0).
  void _advancePhase(Emitter<PomodoroState> emit) {
    if (state.phase == PomodoroPhase.longBreak) {
      if (state.isRepeat) {
        _phaseEndTime = DateTime.now().add(
          Duration(seconds: state.selectedPreset.focusMinutes * 60),
        );
        _persistState();
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
        _phaseEndTime = null;
        _clearPersistedState();
        notificationService.cancelPomodoroNotifications();
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

    final next = _nextPhase(
      state.phase,
      state.cycleIndex,
      state.selectedPreset.cyclesBeforeLongBreak,
    );

    _phaseEndTime = DateTime.now().add(
      Duration(seconds: _secondsForPhase(next.phase, state.selectedPreset)),
    );
    _persistState();

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

    final uid = _userId ?? '';

    final presetsResult = await getPresets(uid);
    if (presetsResult.isLeft()) return;

    final presets = presetsResult.getOrElse((_) => []);
    emit(state.copyWith(presets: [classicPreset, ...presets]));
  }

  Future<void> _onDeletePreset(
    PomodoroDeletePreset event,
    Emitter<PomodoroState> emit,
  ) async {
    final uid = _userId ?? '';

    final result = await deletePreset(uid, event.presetId);
    if (result.isLeft()) return;
    final wasSelected = state.selectedPreset.id == event.presetId;
    if (wasSelected) {
      _cancelTimer();
      _phaseEndTime = null;
      _clearPersistedState();
      notificationService.cancelPomodoroNotifications();
    }

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
    if (state.isRunning) _persistState();
  }

  void _onAppPaused(
    PomodoroAppPaused event,
    Emitter<PomodoroState> emit,
  ) {
    if (!state.isRunning || _phaseEndTime == null) return;

    // Stop the periodic timer to save battery while backgrounded.
    // The DateTime anchor keeps the truth.
    _cancelTimer();
    _persistState();

    // Show a sticky notification so the user knows the timer is active.
    final l10n = lookupAppLocalizations(localeNotifier.value);
    final phaseName = switch (state.phase) {
      PomodoroPhase.focus => l10n.pomodoroPhaseLabel_focus,
      PomodoroPhase.shortBreak => l10n.pomodoroPhaseLabel_shortBreak,
      PomodoroPhase.longBreak => l10n.pomodoroPhaseLabel_longBreak,
    };

    final endTimeStr =
        '${_phaseEndTime!.hour.toString().padLeft(2, '0')}:'
        '${_phaseEndTime!.minute.toString().padLeft(2, '0')}';

    notificationService.showPomodoroOngoing(
      title: l10n.notifPomodoroOngoingTitle(phaseName),
      body: l10n.notifPomodoroOngoingBody(endTimeStr),
    );

    // Schedule a notification for when this phase ends.
    notificationService.schedulePomodoroPhaseEnd(
      phaseEndTime: _phaseEndTime!,
      title: l10n.notifPomodoroPhaseEndTitle(phaseName),
      body: l10n.notifPomodoroPhaseEndBody,
    );
  }

  void _onAppResumed(
    PomodoroAppResumed event,
    Emitter<PomodoroState> emit,
  ) {
    // Cancel background notifications — we're back in foreground.
    notificationService.cancelPomodoroNotifications();

    if (!state.isRunning || _phaseEndTime == null) return;

    // Fast-forward through any phases that elapsed while backgrounded.
    var currentPhase = state.phase;
    var currentCycle = state.cycleIndex;
    var endTime = _phaseEndTime!;

    while (endTime.isBefore(DateTime.now())) {
      if (currentPhase == PomodoroPhase.longBreak) {
        if (state.isRepeat) {
          currentPhase = PomodoroPhase.focus;
          currentCycle = 0;
          endTime = endTime.add(
            Duration(seconds: _secondsForPhase(currentPhase, state.selectedPreset)),
          );
        } else {
          // Session finished while in background
          _phaseEndTime = null;
          _clearPersistedState();
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
          return;
        }
      } else {
        final next = _nextPhase(
          currentPhase,
          currentCycle,
          state.selectedPreset.cyclesBeforeLongBreak,
        );
        currentPhase = next.phase;
        currentCycle = next.cycleIndex;
        endTime = endTime.add(
          Duration(seconds: _secondsForPhase(currentPhase, state.selectedPreset)),
        );
      }
    }

    _phaseEndTime = endTime;
    final remaining = endTime.difference(DateTime.now()).inSeconds.clamp(0, 99999);

    emit(
      PomodoroState(
        presets: state.presets,
        selectedPreset: state.selectedPreset,
        phase: currentPhase,
        cycleIndex: currentCycle,
        secondsRemaining: remaining,
        isRunning: true,
        isFinished: false,
        isRepeat: state.isRepeat,
      ),
    );

    _persistState();
    _startTimer();
  }

  void _startTimer() {
    _cancelTimer();
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

  void _persistState() {
    sharedPreferences.setBool(_kIsRunning, true);
    sharedPreferences.setInt(
      _kPhaseEndTime,
      _phaseEndTime?.millisecondsSinceEpoch ?? 0,
    );
    sharedPreferences.setInt(_kPhase, state.phase.index);
    sharedPreferences.setInt(_kCycleIndex, state.cycleIndex);
    sharedPreferences.setBool(_kIsRepeat, state.isRepeat);
    sharedPreferences.setString(_kPresetId, state.selectedPreset.id);
  }

  void _clearPersistedState() {
    sharedPreferences.remove(_kIsRunning);
    sharedPreferences.remove(_kPhaseEndTime);
    sharedPreferences.remove(_kPhase);
    sharedPreferences.remove(_kCycleIndex);
    sharedPreferences.remove(_kIsRepeat);
    sharedPreferences.remove(_kPresetId);
  }

  @override
  Future<void> close() {
    _cancelTimer();
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}

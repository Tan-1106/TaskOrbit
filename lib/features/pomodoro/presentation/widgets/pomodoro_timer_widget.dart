import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_phase.dart';
import 'package:task_orbit/features/pomodoro/domain/entities/pomodoro_preset.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_state.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

Color phaseColor(PomodoroPhase phase, BuildContext context) {
  return switch (phase) {
    PomodoroPhase.focus => const Color(0xFF5C6BC0), // Indigo
    PomodoroPhase.shortBreak => const Color(0xFF66BB6A), // Green
    PomodoroPhase.longBreak => const Color(0xFFFFA726), // Amber
  };
}

class PomodoroTimerWidget extends StatelessWidget {
  final PomodoroState state;

  const PomodoroTimerWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preset = state.selectedPreset;
    final totalSeconds = _totalSeconds(state.phase, preset);
    final progress = totalSeconds > 0 ? state.secondsRemaining / totalSeconds : 0.0;
    final color = phaseColor(state.phase, context);

    final minutes = state.secondsRemaining ~/ 60;
    final seconds = state.secondsRemaining % 60;
    final timeLabel = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final phaseLabel = switch (state.phase) {
      PomodoroPhase.focus => l10n.pomodoroPhaseLabel_focus,
      PomodoroPhase.shortBreak => l10n.pomodoroPhaseLabel_shortBreak,
      PomodoroPhase.longBreak => l10n.pomodoroPhaseLabel_longBreak,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: progress, end: progress),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, _) {
            return SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: value,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          phaseLabel,
                          key: ValueKey(state.phase),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
        _CycleDots(
          total: preset.cyclesBeforeLongBreak,
          completed: state.cycleIndex,
          color: color,
          phase: state.phase,
        ),
      ],
    );
  }

  int _totalSeconds(PomodoroPhase phase, PomodoroPreset preset) {
    return switch (phase) {
      PomodoroPhase.focus => preset.focusMinutes * 60,
      PomodoroPhase.shortBreak => preset.shortBreakMinutes * 60,
      PomodoroPhase.longBreak => preset.longBreakMinutes * 60,
    };
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 12;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}

class _CycleDots extends StatelessWidget {
  final int total;
  final int completed;
  final Color color;
  final PomodoroPhase phase;

  const _CycleDots({
    required this.total,
    required this.completed,
    required this.color,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isFilled = i < completed;
        // The current active focus slot (during focus phase, not yet complete)
        final isActive = i == completed && phase == PomodoroPhase.focus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 10,
          height: isActive ? 12 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? color
                : isActive
                ? color.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}

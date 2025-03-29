import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neuro_pro/assets/colors/app_colors.dart';

import 'CustomDialogExit.dart';

class ProgressBar extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final double diameter;
  final double fontSize;
  final Function(int step) onStepTapped; // Функция, вызываемая при нажатии на шаг

  const ProgressBar({
    Key? key,
    required this.currentStep,
    this.totalSteps = 9, // По умолчанию 9 шагов
    required this.diameter,
    required this.fontSize,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  Timer? _longPressTimer;

  void _startLongPressTimer() {
    // Запускаем таймер на 2 секунды
    _longPressTimer = Timer(const Duration(seconds: 1), () async {
      // По истечении 3 секунд показываем диалог
      await showExitConfirmationDialog(context);
    });
  }

  void _cancelLongPressTimer() {
    if (_longPressTimer?.isActive ?? false) {
      _longPressTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _cancelLongPressTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Обрабатываем начало нажатия
      onLongPressStart: (details) {
        _startLongPressTimer();
      },
      // Если палец отпускают раньше 3 секунд, таймер отменяется
      onLongPressEnd: (details) {
        _cancelLongPressTimer();
      },
      // При обычном коротком нажатии на отдельные шаги обрабатываем по-старому
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.totalSteps, (index) {
          final step = index + 1;
          return GestureDetector(
            onTap: () {
              if (step <= widget.currentStep) {
                widget.onStepTapped(step);
              }
            },
            child: _buildStepCircle(
              step: step,
              isCurrent: step == widget.currentStep,
              isCompleted: step < widget.currentStep,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle({
    required int step,
    required bool isCurrent,
    required bool isCompleted,
  }) {
    Color fillColor;
    Color borderColor;
    Color textColor;

    if (isCurrent) {
      fillColor = AppColors.primaryColor;
      borderColor = fillColor;
      textColor = AppColors.thirdColor;
    } else if (isCompleted) {
      fillColor = AppColors.progressFill1Color;
      borderColor = AppColors.progressFill2Color;
      textColor = AppColors.thirdColor;
    } else {
      fillColor = Colors.transparent;
      borderColor = AppColors.progressFill2Color;
      textColor = AppColors.primaryColor;
    }

    return Container(
      width: widget.diameter,
      height: widget.diameter,
      child: Stack(
        children: [
          Container(
            width: widget.diameter,
            height: widget.diameter,
            decoration: ShapeDecoration(
              color: fillColor,
              shape: OvalBorder(
                side: BorderSide(width: 3.14, color: borderColor),
              ),
            ),
          ),
          Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


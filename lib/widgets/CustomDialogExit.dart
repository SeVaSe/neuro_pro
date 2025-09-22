import 'package:flutter/material.dart';

import '../assets/colors/app_colors.dart';
import '../firstClassific/diagnostics/diagnostic_page5.dart';
import '../firstClassific/basic/home_screen.dart';
import '../firstClassific/diagnostics/diagnostic_page6.dart';
import '../services/logger.dart';
import '../services/temp_storage.dart';

Future<bool?> showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение', style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),),
        content: const Text('Вы точно хотите закончить диагностику досрочно?', style: TextStyle(color: AppColors.text2Color),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Отмена
            child: const Text('Нет', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтверждение
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()), // Переход на домашнюю страницу
                    (route) => false, // Удаляем все предыдущие маршруты
              );
            },
            child: const Text('Да', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
        ],
      );
    },
  );
}

Future<bool?> showExitConfirmationTempDialog(BuildContext context, TempStorage tempStorage) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение', style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),),
        content: const Text('Вы точно хотите закончить скриннинг?', style: TextStyle(color: AppColors.text2Color),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Отмена
            child: const Text('Нет', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтверждение
              tempStorage.clearAllData();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(tempStorage: tempStorage)), // Переход на домашнюю страницу
                    (route) => false, // Удаляем все предыдущие маршруты
              );
            },
            child: const Text('Да', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
        ],
      );
    },
  );
}

Future<bool?> showExitConfirmationTempReymDialog3(BuildContext context, TempStorage tempStorage) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение', style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),),
        content: const Text('Вы точно хотите закончить скриннинг?', style: TextStyle(color: AppColors.text2Color),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Отмена
            child: const Text('Нет', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтверждение
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(tempStorage: tempStorage)), // Переход на домашнюю страницу
                    (route) => false, // Удаляем все предыдущие маршруты
              );
            },
            child: const Text('Да', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
        ],
      );
    },
  );
}


Future<bool?> showExitConfirmationTempReymDialog(BuildContext context, TempStorage tempStorage) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение', style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),),
        content: const Text('Вы точно хотите закончить скриннинг?', style: TextStyle(color: AppColors.text2Color),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Отмена
            child: const Text('Нет', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтверждение
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DiagnosticPage5(
                    currentStep: 5, // Передаем номер текущего шага
                    tempStorage: tempStorage, // Передаем хранилище данных
                  ),
                ), (route) => false, // Удаляем все предыдущие маршруты
              );
            },
            child: const Text('Да', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
        ],
      );
    },
  );
}

Future<bool?> showExitConfirmationTempReymDialog2(BuildContext context, TempStorage tempStorage) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение', style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),),
        content: const Text('Вы точно хотите закончить скриннинг?', style: TextStyle(color: AppColors.text2Color),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Отмена
            child: const Text('Нет', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтверждение
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DiagnosticPage5(
                    currentStep: 5, // Передаем номер текущего шага
                    tempStorage: tempStorage, // Передаем хранилище данных
                  ),
                ), (route) => false, // Удаляем все предыдущие маршруты
              );
            },
            child: const Text('Да', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
          ),
        ],
      );
    },
  );
}



Future<bool?> showCancelConfirmationDialog(BuildContext context, TempStorage tempStorage) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,  // Запрещает закрытие при клике вне окна
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'У пациента есть рентгенограмма?',
          style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),
        ),
        content: const Text(
          'У пациента есть рентгенограмма?',
          style: TextStyle(color: AppColors.text2Color),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтверждение
              tempStorage.saveData('diagnostic4.xray', 'У пациента отсутствует рентгенограмма');
              DiagnosticLogger.logDiagnostic('Необходимость ренгена', 'diagnostic4.xray', tempStorage);

              tempStorage.saveData('diagnostic5.reimers', 'У пациента отсутствует рентгенограмма');
              DiagnosticLogger.logDiagnostic('Реймерс', 'diagnostic5.reimers', tempStorage);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DiagnosticPage6(
                    currentStep: 6, // Передаем номер текущего шага
                    tempStorage: tempStorage, // Передаем хранилище данных
                  ),
                ),
                    (route) => false, // Удаляем все предыдущие маршруты
              );
            },
            child: const Text(
              'Нету',
              style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Отмена
            child: const Text(
              'Есть',
              style: TextStyle(color: AppColors.errorColor, fontFamily: 'TinosBold'),
            ),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page8.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../assets/colors/app_colors.dart';
import '../../widgets/CustomResultCard.dart';

class DiagnosticPage7 extends StatelessWidget {
  final int currentStep; // Номер текущего этапа (1-9)
  final TempStorage tempStorage; // Хранилище данных

  const DiagnosticPage7({Key? key, required this.currentStep, required this.tempStorage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Пропорциональные размеры
    final double progressDiameter = screenWidth * 0.1; // Диаметр кружка
    final double progressFontSize = screenWidth * 0.05;

    // Получение данных из хранилища
    final diagnosticType = tempStorage.getData('diagnostic1.type');
    String displayedText;

    if (diagnosticType == 'Спастический' ||
        diagnosticType == 'Дискинетический' ||
        diagnosticType == 'Смешанный') {
      displayedText = AppStrings.butoTextYESString;
      tempStorage.saveData('diagnostic7.buto', displayedText);
      DiagnosticLogger.logDiagnostic('Буто', 'diagnostic7.buto', tempStorage);
    } else if (diagnosticType == 'Атаксический') {
      displayedText = AppStrings.butoTextNOString;
      tempStorage.saveData('diagnostic7.buto', displayedText);
      DiagnosticLogger.logDiagnostic('Буто', 'diagnostic7.buto', tempStorage);
    } else {
      displayedText = 'Данные не определены';
    }

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false; // Возвращает true, если пользователь подтвердил выход
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Шкала прогресса (используем виджет ProgressBar)
            Positioned(
              top: screenHeight * 0.05,
              left: 0,
              right: 0,
              child: ProgressBar(
                currentStep: currentStep,
                totalSteps: 9,
                diameter: progressDiameter,
                fontSize: progressFontSize,
                onStepTapped: (step) {
                  if (step < currentStep) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => getStepPage(step, tempStorage),
                      ),
                    );
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Вы уже находитесь на данном шаге!'), backgroundColor: AppColors.errorColor,),
                    );
                  }
                },
              ),
            ),

            // Контент страницы
            // Контент страницы
            Positioned.fill(
              top: screenHeight * 0.25, // Отступ от шкалы прогресса
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView( // Добавляем прокрутку
                  child: Column(
                    children: [
                      // Заголовок "Направить на ботулинотерапию?" (по центру)
                      Text(
                        AppStrings.nameTitle7String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                          fontFamily: 'TinosBold',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Отображаемый текст в зависимости от данных из хранилища
                      ResultCard(
                        text: displayedText,
                      ),

                      const SizedBox(height: 20),
                      // Кнопка "Далее"
                      GestureDetector(
                        onTap: () {
                          // Переход на следующий экран
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosticPage8(
                                currentStep: currentStep + 1, // Передаем номер текущего шага
                                tempStorage: tempStorage, // Передаем хранилище данных
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.065,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.buttonCancelString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // небольшое расстояние перед кнопкой справки
                      GestureDetector(
                        onTap: () {
                          int index = 6;
                          showDialog(
                            context: context,
                            builder: (context) => SpravkaDialog(index: index),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.45,
                          height: screenHeight * 0.05,
                          decoration: ShapeDecoration(
                            color: const Color(0x004DCDC2),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 3.14, color: AppColors.secondryColor),
                              borderRadius: BorderRadius.circular(screenWidth * 0.08),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.buttonSpravkaString,
                              style: TextStyle(
                                color: AppColors.text1Color,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

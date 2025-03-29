import 'package:flutter/material.dart';
import 'package:neuro_pro/assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomProgressBar.dart';
import 'diagnostic_page2.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../assets/colors/app_colors.dart';


class DiagnosticPage1 extends StatelessWidget {
  final int currentStep; // Номер текущего этапа (1-9)
  final TempStorage tempStorage; // Хранилище данных

  const DiagnosticPage1({Key? key, required this.currentStep, required this.tempStorage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Пропорциональные размеры
    final double progressDiameter = screenWidth * 0.1; // Диаметр кружка
    final double progressFontSize = screenWidth * 0.05;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false; // Возвращает true, если пользователь подтвердил выход
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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

            Positioned.fill(
              top: screenHeight * 0.25,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Заголовок "Тип ДЦП" (по центру)
                      Text(
                        AppStrings.nameTitle1String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                          fontFamily: 'TinosBold',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Блок кнопок выбора
                      _buildOptionButton(context, AppStrings.buttonSpastichString, 'diagnostic1.type', screenWidth * 0.9, screenHeight * 0.065),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.buttonDiscenitichString, 'diagnostic1.type', screenWidth * 0.9, screenHeight * 0.065),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.buttonAtaksichString, 'diagnostic1.type', screenWidth * 0.9, screenHeight * 0.065),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.buttonSmeshString, 'diagnostic1.type', screenWidth * 0.9, screenHeight * 0.065),

                      const SizedBox(height: 20), // Добавил отступ

                      // Кнопка справки
                      GestureDetector(
                        onTap: () {
                          // Проверяем, если есть URL в JSON
                          int index = 0;
                          showDialog(
                            context: context,
                            builder: (context) => SpravkaDialog(index: index, id: 0),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.45,
                          height: screenHeight * 0.05,
                          decoration: ShapeDecoration(
                            color: const Color(0x004DCDC2),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 3.14, color: AppColors.secondryColor),
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

  /// Кнопка для выбора типа
  Widget _buildOptionButton(BuildContext context, String label, String key, double width, double height) {
    return GestureDetector(
      onTap: () {
        // Сохраняем значение выбора
        tempStorage.saveData(key, label);
        // Получаем сохраненные данные (для проверки)
        DiagnosticLogger.logDiagnostic('Диагностический тип', 'diagnostic1.type', tempStorage);

        // Переход на второй шаг (DiagnosticPage2)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosticPage2(
              currentStep: currentStep+1, // Передаем номер текущего шага
              tempStorage: tempStorage, // Передаем хранилище данных
            ),
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.thirdColor,
              fontSize: width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

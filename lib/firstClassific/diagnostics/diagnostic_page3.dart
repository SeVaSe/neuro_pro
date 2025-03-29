import 'package:flutter/material.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import 'diagnostic_page4.dart';
import '../../widgets/CustomProgressBar.dart';

class DiagnosticPage3 extends StatelessWidget {
  final int currentStep;
  final TempStorage tempStorage;

  const DiagnosticPage3(
      {Key? key, required this.currentStep, required this.tempStorage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Пропорциональные размеры
    final double progressDiameter = screenWidth * 0.1;
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Вы уже находитесь на данном шаге!'),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned.fill(
              top: screenHeight * 0.25,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView( // Добавляем прокрутку
                  child: Column(
                    children: [
                      Text(
                        AppStrings.nameTitle3String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                          fontFamily: 'TinosBold',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildOptionButton(context, AppStrings.button1levelString, 'level 1',
                          screenWidth, screenHeight),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.button2levelString, 'level 2',
                          screenWidth, screenHeight),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.button3levelString, 'level 3',
                          screenWidth, screenHeight),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.button4levelString, 'level 4',
                          screenWidth, screenHeight),
                      const SizedBox(height: 15),
                      _buildOptionButton(context, AppStrings.button5levelString, 'level 5',
                          screenWidth, screenHeight),
                      const SizedBox(height: 15), // Это дополнительное пространство
                      GestureDetector(
                        onTap: () {
                          int index = 1;
                          showDialog(
                            context: context,
                            builder: (context) => SpravkaDialog(index: index, id: 1),
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
                              borderRadius:
                              BorderRadius.circular(screenWidth * 0.08),
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

  Widget _buildOptionButton(BuildContext context, String label, String levelKey,
      double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        _showLevelDialog(context, label, levelKey);
      },
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.065,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.thirdColor,
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showLevelDialog(
      BuildContext context, String levelLabel, String levelKey) {
    final int age = int.parse(tempStorage.getData('diagnostic2.age'));
    String description = AppStrongStrings().getLevelDescription(age, levelKey);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(levelLabel,
          style: TextStyle(color: AppColors.secondryColor, fontFamily: 'TinosBold'),),
          content: SingleChildScrollView(  // Оборачиваем содержимое в SingleChildScrollView
            child: Text(description,
            style: TextStyle(color: AppColors.text2Color),),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
            ),
            TextButton(
              onPressed: () {
                tempStorage.saveData('diagnostic3.gmfcs', levelKey);
                DiagnosticLogger.logDiagnostic('GMFCS', 'diagnostic3.gmfcs', tempStorage);

                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiagnosticPage4(
                      currentStep: currentStep+1, // Передаем номер текущего шага
                      tempStorage: tempStorage, // Передаем хранилище данных
                    ),
                  ),
                );
              },
              child: const Text('Подтвердить', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
            ),
          ],
        );
      },
    );
  }
}

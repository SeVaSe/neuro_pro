import 'package:flutter/material.dart';
import 'package:neuro_pro/assets/data/texts/strings.dart';
import '../../assets/colors/app_colors.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import 'diagnostic_page3.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomDialogExit.dart';

class DiagnosticPage2 extends StatefulWidget {
  final int currentStep; // Номер текущего этапа (2)
  final TempStorage tempStorage; // Хранилище данных

  const DiagnosticPage2({Key? key, required this.currentStep, required this.tempStorage}) : super(key: key);

  @override
  _DiagnosticPage2State createState() => _DiagnosticPage2State();
}

class _DiagnosticPage2State extends State<DiagnosticPage2> {
  // Контроллер для текстового поля
  TextEditingController ageController = TextEditingController();

  // FocusNode для управления фокусом
  FocusNode ageFocusNode = FocusNode();

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
            // Шкала прогресса
            Positioned(
              top: screenHeight * 0.05,
              left: 0,
              right: 0,
              child: ProgressBar(
                currentStep: widget.currentStep,
                totalSteps: 9,
                diameter: progressDiameter,
                fontSize: progressFontSize,
                onStepTapped: (step) {
                  if (step < widget.currentStep) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => getStepPage(step, widget.tempStorage),
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
            Positioned.fill(
              top: screenHeight * 0.25,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.nameTitle2String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                          fontFamily: 'TinosBold',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: ageController,
                        focusNode: ageFocusNode, // Привязываем FocusNode к TextField
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Введите возраст',
                          labelStyle: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: AppColors.secondryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          String age = ageController.text;

                          // Проверка на валидность возраста
                          if (age.isNotEmpty) {
                            int ageValue = int.tryParse(age) ?? -1;

                            if (ageValue >= 0 && ageValue <= 18) {
                              widget.tempStorage.saveData('diagnostic2.age', age);
                              DiagnosticLogger.logDiagnostic('Возраст', 'diagnostic2.age', widget.tempStorage);

                              // Переход на следующий экран
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DiagnosticPage3(
                                    currentStep: widget.currentStep + 1,
                                    tempStorage: widget.tempStorage,
                                  ),
                                ),
                              );
                            } else {
                              // Ошибка: Возраст вне диапазона
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ошибка: Возраст должен быть от 0 до 18 лет'),
                                  backgroundColor: AppColors.errorColor,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            // Ошибка: Возраст не введен
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ошибка: Пожалуйста, введите возраст'),
                                backgroundColor: AppColors.errorColor,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.065,
                          decoration: ShapeDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.buttonCancelString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  @override
  void dispose() {
    ageController.dispose(); // Освобождаем ресурсы
    ageFocusNode.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomCheckboxes.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomResultCard.dart';
import 'diagnostic_page5.dart';


class DiagnosticPage4 extends StatefulWidget {
  final int currentStep;
  final TempStorage tempStorage;

  const DiagnosticPage4({Key? key, required this.currentStep, required this.tempStorage}) : super(key: key);

  @override
  State<DiagnosticPage4> createState() => _DiagnosticPage4State();
}

class _DiagnosticPage4State extends State<DiagnosticPage4> {
  bool xrayAt2Yes = false;
  bool xrayAt2No = false;
  bool xrayAt6Yes = false;
  bool xrayAt6No = false;
  bool xrayAt9Yes = false;
  bool xrayAt9No = false;

  @override
  void initState() {
    super.initState();
    // Показываем диалог после первого рендера экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCancelConfirmationDialog(context, widget.tempStorage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Пропорциональные размеры
    final double progressDiameter = screenWidth * 0.1;
    final double progressFontSize = screenWidth * 0.05;

    int age = int.parse(widget.tempStorage.getData('diagnostic2.age'));
    String level = widget.tempStorage.getData('diagnostic3.gmfcs');
    String message = _determineXraySchedule(age, level);

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Верхняя область с ProgressBar
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
            // Основное содержимое с прокруткой
            Positioned(
              top: screenHeight * 0.25, // Расположение от верхней границы экрана
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                // Здесь можно задать дополнительный отступ сверху, если нужно
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.nameTitle4String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondryColor,
                        fontSize: screenWidth * 0.10,
                        fontFamily: 'TinosBold',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (level == 'level 2')
                      Column(
                        children: [
                          if (age > 2)
                            _buildCheckboxRow(
                              screenWidth,
                              'Ребенок делал рентген в 2 года?',
                              xrayAt2Yes,
                              xrayAt2No,
                                  (value) {
                                setState(() {
                                  xrayAt2Yes = value;
                                  if (value) xrayAt2No = false;
                                });
                              },
                                  (value) {
                                setState(() {
                                  xrayAt2No = value;
                                  if (value) xrayAt2Yes = false;
                                });
                              },
                            ),
                          if (age >= 6)
                            _buildCheckboxRow(
                              screenWidth,
                              'Ребенок делал рентген в 6 лет?',
                              xrayAt6Yes,
                              xrayAt6No,
                                  (value) {
                                setState(() {
                                  xrayAt6Yes = value;
                                  if (value) xrayAt6No = false;
                                });
                              },
                                  (value) {
                                setState(() {
                                  xrayAt6No = value;
                                  if (value) xrayAt6Yes = false;
                                });
                              },
                            ),
                          if (age >= 10)
                            _buildCheckboxRow(
                              screenWidth,
                              'Ребенок делал рентген в 10 лет?',
                              xrayAt9Yes,
                              xrayAt9No,
                                  (value) {
                                setState(() {
                                  xrayAt9Yes = value;
                                  if (value) xrayAt9No = false;
                                });
                              },
                                  (value) {
                                setState(() {
                                  xrayAt9No = value;
                                  if (value) xrayAt9Yes = false;
                                });
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    if (message.isNotEmpty)
                      ResultCard(
                        text: message,
                      ),
                    const SizedBox(height: 30),
                    // Первая кнопка – размеры не меняем
                    GestureDetector(
                      onTap: () {
                        if (_areAllQuestionsAnswered(age)) {
                          _saveXraySchedule(age, level);
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosticPage5(
                                currentStep: widget.currentStep + 1,
                                tempStorage: widget.tempStorage,
                              ),
                            ),
                          );
                        } else {
                          _showSnackBarError(context);
                        }
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
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Вторая кнопка
                    GestureDetector(
                      onTap: () {
                        int index = 2;
                        showDialog(
                          context: context,
                          builder: (context) =>
                              SpravkaDialog(index: index, id: 2),
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.05,
                        decoration: ShapeDecoration(
                          color: const Color(0x004DCDC2),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 3.14,
                              color: AppColors.secondryColor,
                            ),
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
          ],
        ),
      ),
    );

  }

  Widget _buildCheckboxRow(
      double screenWidth,
      String question,
      bool yesValue,
      bool noValue,
      ValueChanged<bool> onYesChanged,
      ValueChanged<bool> onNoChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.secondryColor,
          ),
        ),
        Row(
          children: [
            Row(
              children: [
                CustomCheckbox(
                  isSelected: yesValue,
                  onChanged: onYesChanged,
                ),
                const SizedBox(width: 10),
                const Text('Да'),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              children: [
                CustomCheckbox(
                  isSelected: noValue,
                  onChanged: onNoChanged,
                ),
                const SizedBox(width: 10),
                const Text('Нет'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  bool _areAllQuestionsAnswered(int age) {
    // Уровень 1, 3, 4, 5 — здесь чекбоксы не должны отображаться, и проверка не требуется
    if (age > 2 && !(xrayAt2Yes || xrayAt2No) && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 1' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 3' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 4' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 5') return false;
    if (age >= 6 && !(xrayAt6Yes || xrayAt6No) && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 1' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 3' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 4' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 5') return false;
    if (age >= 10 && !(xrayAt9Yes || xrayAt9No) && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 1' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 3' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 4' && widget.tempStorage.getData('diagnostic3.gmfcs') != 'level 5') return false;

    return true;
  }


  void _showSnackBarError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Пожалуйста, ответьте на все вопросы перед продолжением.',
          style: TextStyle(color: AppColors.thirdColor),
        ),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _determineXraySchedule(int age, String level) {
    // Для уровня 'level2', если возраст от 0 до 2 лет, текст всегда отображается
    if (level == 'level 2' && age <= 2) {
      return 'Назначен рентген в 2 и 6 лет.';  // Можете изменить текст по своему усмотрению
    }

    // Не показывать текст, если чекбоксы не выбраны, но только для level2
    if (level == 'level 2' && !_isAnyCheckboxSelected()) {
      return ''; // Не отображать текст, если ни один чекбокс не выбран
    }

    if (level == 'level 1') {
      return 'Рентген не требуется.';
    } else if (level == 'level 2') {
      if (age < 2) {
        return 'Назначен рентген в 2 и 6 лет.';
      } else if (age >= 2 && age < 6) {
        if (!xrayAt2Yes) {
          return 'Назначен рентген сейчас и в 6 лет.';
        }
        return 'Назначен рентген в 6 лет.';
      } else if (age >= 6 && age < 10) {
        if (!xrayAt2Yes && !xrayAt6Yes) {
          return 'Назначен рентген сейчас и в 10 лет.';
        } else if (xrayAt2Yes && !xrayAt6Yes) {
          return 'Назначен рентген сейчас и в 10 лет.';
        } else if (!xrayAt2Yes && xrayAt6Yes) {
          return 'Назначен рентген в 10 лет.';
        }
        return 'Назначен рентген в 10 лет.';
      } else if (age >= 10) {
        if (!xrayAt9Yes) {
          return 'Назначен рентген сейчас.';
        }
        return 'Все рентгены для вашего уровня выполнены.';
      }
    } else if (level == 'level 3' || level == 'level 4' || level == 'level 5') {
      return 'Назначен ежегодный рентген.';
    }
    return 'Уровень не определен.';
  }


  bool _isAnyCheckboxSelected() {
    return xrayAt2Yes || xrayAt2No || xrayAt6Yes || xrayAt6No || xrayAt9Yes || xrayAt9No;
  }


  void _saveXraySchedule(int age, String level) {
    String schedule = _determineXraySchedule(age, level);
    widget.tempStorage.saveData('diagnostic4.xray', schedule);
    DiagnosticLogger.logDiagnostic('Необходимость ренгена', 'diagnostic4.xray', widget.tempStorage);
  }
}





import 'package:flutter/material.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomCheckboxes.dart';
import '../../widgets/CustomResultCard.dart';
import 'diagnostic_page7.dart';

class DiagnosticPage6 extends StatefulWidget {
  final int currentStep;
  final TempStorage tempStorage;

  const DiagnosticPage6({
    Key? key,
    required this.currentStep,
    required this.tempStorage,
  }) : super(key: key);

  @override
  _DiagnosticPage6State createState() => _DiagnosticPage6State();
}

class _DiagnosticPage6State extends State<DiagnosticPage6> {
  String? boneDensitySelection;
  String? endocrinologistReferral;
  bool isYesSelected = false;
  bool isNoSelected = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double progressDiameter = screenWidth * 0.1;
    final double progressFontSize = screenWidth * 0.05;

    String? gmfcsLevel = widget.tempStorage.getData('diagnostic3.gmfcs');

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false; // Возвращает true, если пользователь подтвердил выход
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // Прогресс-бар
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Center(
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
                ),
                // Заголовок
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Text(
                    AppStrings.nameTitle6String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondryColor,
                      fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                      fontFamily: 'TinosBold',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // Проверка уровня GMFCS
                if (gmfcsLevel == 'level 1' || gmfcsLevel == 'level 2' || gmfcsLevel == 'level 3')
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                        child: ResultCard(
                          text: 'Денситометрия проводится только при уровне 4 и 5.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          widget.tempStorage.saveData('diagnostic6.densimetr', "Денситометрия при 1-3 уровне GMFCS не делается");
                          DiagnosticLogger.logDiagnostic('Денситометрия', 'diagnostic6.densimetr', widget.tempStorage);

                          widget.tempStorage.saveData('diagnostic6.endocrin', "В направлении к эндокринологу не нуждается");
                          DiagnosticLogger.logDiagnostic('Эндокринолог', 'diagnostic6.endocrin', widget.tempStorage);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosticPage7(
                                currentStep: widget.currentStep + 1,
                                tempStorage: widget.tempStorage,
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
                    ],
                  )
                else
                // Стандартная часть с кнопками "Да" и "Нет"
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isYesSelected = true;
                              isNoSelected = false;
                            });
                          },
                          child: _buildButton(
                            label: 'Да',
                            isSelected: isYesSelected,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isYesSelected = false;
                              isNoSelected = true;
                            });

                            widget.tempStorage.saveData('diagnostic6.densimetr', "нет");
                            DiagnosticLogger.logDiagnostic('Денситометрия', 'diagnostic6.densimetr', widget.tempStorage);

                            endocrinologistReferral = 'В направлении к эндокринологу не нуждается';
                            widget.tempStorage.saveData('diagnostic6.endocrin', endocrinologistReferral);
                            DiagnosticLogger.logDiagnostic('Эндокринолог', 'diagnostic6.endocrin', widget.tempStorage);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiagnosticPage7(
                                  currentStep: widget.currentStep + 1,
                                  tempStorage: widget.tempStorage,
                                ),
                              ),
                            );
                          },
                          child: _buildButton(
                            label: 'Нет',
                            isSelected: isNoSelected,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Если выбрано "Да", дополнительные вопросы
                if (isYesSelected)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildQuestion(
                            label:
                            'Выявлено ли у пациента снижение плотности костной ткани?',
                            options: ['Остеопения', 'Остеопороз', 'Не выявлено'],
                            selectedValue: boneDensitySelection,
                            onOptionSelected: (value) {
                              setState(() {
                                boneDensitySelection = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildQuestion(
                            label:
                            'Надо ли отправлять к эндокринологу на назначение бисфосфонатов?',
                            options: ['Да', 'Нет'],
                            selectedValue: endocrinologistReferral,
                            onOptionSelected: (value) {
                              setState(() {
                                endocrinologistReferral = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              if (isYesSelected &&
                                  (boneDensitySelection == null ||
                                      endocrinologistReferral == null)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Пожалуйста, ответьте на оба вопроса!',
                                      style: TextStyle(color: AppColors.thirdColor),
                                    ),
                                    backgroundColor: AppColors.errorColor,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                widget.tempStorage.saveData('diagnostic6.densimetr', boneDensitySelection);
                                DiagnosticLogger.logDiagnostic('Денситометрия', 'diagnostic6.densimetr', widget.tempStorage);

                                if (endocrinologistReferral == 'Да') {
                                  endocrinologistReferral = AppStrings.endocrinologistReferralYESString;
                                }
                                else {
                                  endocrinologistReferral = AppStrings.endocrinologistReferralNOString;
                                }

                                widget.tempStorage.saveData('diagnostic6.endocrin', endocrinologistReferral);
                                DiagnosticLogger.logDiagnostic('Эндокринолог', 'diagnostic6.endocrin', widget.tempStorage);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiagnosticPage7(
                                      currentStep: widget.currentStep + 1,
                                      tempStorage: widget.tempStorage,
                                    ),
                                  ),
                                );
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
                                    fontSize: screenWidth * 0.05,
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
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    int index = 5;
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
          ],
        ),
      ),
    );
  }



  Widget _buildButton({
    required String label,
    required bool isSelected,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      width: screenWidth * 0.4,
      height: screenHeight * 0.065,
      decoration: ShapeDecoration(
        gradient: isSelected
            ? AppColors.primaryGradient
            : null,
        color: isSelected ? null : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          side: const BorderSide(color: AppColors.secondryColor, width: 2.0),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.thirdColor : AppColors.secondryColor,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onOptionSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text1Color,
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              CustomCheckbox(
                isSelected: selectedValue == option,
                onChanged: (isSelected) {
                  if (isSelected) {
                    onOptionSelected(option);
                  }
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(
                    color: AppColors.text1Color,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

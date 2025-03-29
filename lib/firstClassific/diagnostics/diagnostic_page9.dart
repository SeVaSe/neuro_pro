import 'package:flutter/material.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page_result.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomCheckboxes.dart';

class DiagnosticPage9 extends StatefulWidget {
  final int currentStep;
  final TempStorage tempStorage;

  const DiagnosticPage9({
    Key? key,
    required this.currentStep,
    required this.tempStorage,
  }) : super(key: key);

  @override
  _DiagnosticPage9State createState() => _DiagnosticPage9State();
}

class _DiagnosticPage9State extends State<DiagnosticPage9> {
  String? boneDensitySelection;
  String? endocrinologistReferral;
  bool isYesSelected = false;
  bool isNoSelected = false;
  List<String> selectedOrthoses = []; // Список выбранных ортезов

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double progressDiameter = screenWidth * 0.1;
    final double progressFontSize = screenWidth * 0.05;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.05, // Прогресс-бар
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
                      SnackBar(content: Text('Вы уже находитесь на данном шаге!'), backgroundColor: AppColors.errorColor),
                    );
                  }
                },
              ),
            ),

            Positioned.fill(
              top: isYesSelected ? screenHeight * 0.15 : screenHeight * 0.25, // Смещение контента
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      isYesSelected ? 'Выбор ортезов' : 'Нужен ли ортез?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondryColor,
                        fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                        fontFamily: 'TinosBold',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!isYesSelected)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isYesSelected = true;
                                isNoSelected = false;
                              });
                            },
                            child: _buildButton(label: 'Да', isSelected: isYesSelected, screenWidth: screenWidth, screenHeight: screenHeight),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isYesSelected = false;
                                isNoSelected = true;
                              });

                              widget.tempStorage.saveData('diagnostic9.ortez', "нет");
                              DiagnosticLogger.logDiagnostic('Ортез', 'diagnostic9.ortez', widget.tempStorage);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DiagnosticPageResult(
                                    currentStep: widget.currentStep + 1,
                                    tempStorage: widget.tempStorage,
                                  ),
                                ),
                              );
                            },
                            child: _buildButton(label: 'Нет', isSelected: isNoSelected, screenWidth: screenWidth, screenHeight: screenHeight),
                          ),
                        ],
                      ),

                    const SizedBox(height: 15),

                    if (isYesSelected)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.001,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildQuestion(
                                options: [
                                  'I тип – сенсомоторная стелька', 'II тип - SMO – супрамалеолярный ортез', 'III тип – SAFO – статический ортез на голеностопный сустав',
                                  'IV тип – DAFO – динамический ортез', 'V тип – HAFO – ортез с шарниром', 'VI тип – GRAFO – ортез с передней поддержкой',
                                  'VII тип – PLS AFO – задний ортез голеностопного сустава с листовой пружиной'
                                ],
                                selectedValues: selectedOrthoses,
                                onOptionSelected: (value) {
                                  setState(() {
                                    if (selectedOrthoses.contains(value)) {
                                      selectedOrthoses.remove(value);
                                    } else {
                                      selectedOrthoses.add(value);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: GestureDetector(
                        onTap: () {
                          if (selectedOrthoses.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Пожалуйста, выберите хотя бы один ортез!', style: TextStyle(color: AppColors.thirdColor)),
                                backgroundColor: AppColors.errorColor,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else {
                            widget.tempStorage.saveData('diagnostic9.ortez', selectedOrthoses.join(', '));
                            DiagnosticLogger.logDiagnostic('Ортез', 'diagnostic9.ortez', widget.tempStorage);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiagnosticPageResult(
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
                    ),

                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        // Проверяем, если есть URL в JSON
                        int index = 8; // замените на реальный индекс, который вы хотите использовать
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
                  ],
                ),
              ),
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
        gradient: isSelected ? AppColors.primaryGradient : null,
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
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<String> onOptionSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((option) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              CustomCheckbox(
                isSelected: selectedValues.contains(option),
                onChanged: (isSelected) {
                  if (isSelected) {
                    onOptionSelected(option);
                  } else {
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

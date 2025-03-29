import 'package:flutter/material.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomResultCard.dart';
import '../screnning/ScrenningPageReym.dart';
import 'diagnostic_page6.dart';

class DiagnosticPage5 extends StatefulWidget {
  final int currentStep; // Номер текущего этапа (1-9)
  final TempStorage tempStorage; // Хранилище данных

  const DiagnosticPage5({Key? key, required this.currentStep, required this.tempStorage}) : super(key: key);

  @override
  _DiagnosticPage5State createState() => _DiagnosticPage5State();
}

class _DiagnosticPage5State extends State<DiagnosticPage5> {
  // Контроллеры для левой стороны
  final TextEditingController _controllerLeftA = TextEditingController();
  final TextEditingController _controllerLeftB = TextEditingController();

  // Контроллеры для правой стороны
  final TextEditingController _controllerRightA = TextEditingController();
  final TextEditingController _controllerRightB = TextEditingController();

  double? _leftIndex;
  double? _rightIndex;

  String? _leftRecommendation;
  String? _rightRecommendation;

  @override
  void initState() {
    super.initState();

    // Загружаем сохранённые данные для левой стороны
    final String? leftDistanceA = widget.tempStorage.getData("screen.left.distanceA");
    final String? leftDistanceB = widget.tempStorage.getData("screen.left.distanceB");
    final String? leftIndexStr = widget.tempStorage.getData("screen.left.index");

    if (leftDistanceA != null) {
      _controllerLeftA.text = leftDistanceA;
    }
    if (leftDistanceB != null) {
      _controllerLeftB.text = leftDistanceB;
    }
    if (leftIndexStr != null) {
      _leftIndex = double.tryParse(leftIndexStr);
      _leftRecommendation = (_leftIndex != null && _leftIndex! <= 33)
          ? 'Наблюдение / SWASH'
          : 'Консультация хирурга';
    }

    // Загружаем сохранённые данные для правой стороны
    final String? rightDistanceA = widget.tempStorage.getData("screen.right.distanceA");
    final String? rightDistanceB = widget.tempStorage.getData("screen.right.distanceB");
    final String? rightIndexStr = widget.tempStorage.getData("screen.right.index");

    if (rightDistanceA != null) {
      _controllerRightA.text = rightDistanceA;
    }
    if (rightDistanceB != null) {
      _controllerRightB.text = rightDistanceB;
    }
    if (rightIndexStr != null) {
      _rightIndex = double.tryParse(rightIndexStr);
      _rightRecommendation = (_rightIndex != null && _rightIndex! <= 33)
          ? 'Наблюдение / SWASH'
          : 'Консультация хирурга';
    }
  }

  void _calculateIndexes() {
    final double? leftA = double.tryParse(_controllerLeftA.text);
    final double? leftB = double.tryParse(_controllerLeftB.text);
    final double? rightA = double.tryParse(_controllerRightA.text);
    final double? rightB = double.tryParse(_controllerRightB.text);

    if (leftA != null && leftB != null && leftB != 0 && rightA != null && rightB != null && rightB != 0) {
      final leftResult = (leftA / leftB) * 100;
      final rightResult = (rightA / rightB) * 100;

      setState(() {
        _leftIndex = leftResult;
        _rightIndex = rightResult;

        _leftRecommendation = (leftResult <= 33) ? 'Наблюдение / SWASH' : 'Консультация хирурга';
        _rightRecommendation = (rightResult <= 33) ? 'Наблюдение / SWASH' : 'Консультация хирурга';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректные значения для всех полей (B ≠ 0)'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _onNextPressed() {
    if (_leftIndex == null || _rightIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Пожалуйста, рассчитайте индекс Реймерса для обеих сторон перед продолжением.',
            style: TextStyle(color: AppColors.thirdColor),
          ),
          backgroundColor: AppColors.errorColor,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Сохраняем данные в хранилище
      widget.tempStorage.saveData("screen.left.distanceA", _controllerLeftA.text);
      widget.tempStorage.saveData("screen.left.distanceB", _controllerLeftB.text);
      widget.tempStorage.saveData("screen.left.index", _leftIndex!.toStringAsFixed(1));

      widget.tempStorage.saveData("screen.right.distanceA", _controllerRightA.text);
      widget.tempStorage.saveData("screen.right.distanceB", _controllerRightB.text);
      widget.tempStorage.saveData("screen.right.index", _rightIndex!.toStringAsFixed(1));

      DiagnosticLogger.logDiagnostic('ИМ/Л', 'screen.left.index', widget.tempStorage);
      DiagnosticLogger.logDiagnostic('ИМ/П', 'screen.right.index', widget.tempStorage);

      widget.tempStorage.saveData('diagnostic5.reimers', '1. Индекс Реймерса (Левая сторона): ${_leftIndex!.toStringAsFixed(1)}%\nРекомендация: $_leftRecommendation' + '\n\n2. Индекс Реймерса (Правая сторона): ${_rightIndex!.toStringAsFixed(1)}%\nРекомендация: $_rightRecommendation',);
      DiagnosticLogger.logDiagnostic('Реймерс', 'diagnostic5.reimers', widget.tempStorage);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosticPage6(
            currentStep: widget.currentStep + 1,
            tempStorage: widget.tempStorage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана для адаптивности
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Пропорциональные размеры для прогресса
    final double progressDiameter = screenWidth * 0.1;
    final double progressFontSize = screenWidth * 0.05;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Прогресс-бар
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

            // Контент страницы с прокруткой
            Positioned.fill(
              top: screenHeight * 0.25,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Заголовок
                      Text(
                        AppStrings.nameTitle5String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: screenWidth * 0.10,
                          fontFamily: 'TinosBold',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Блок для левой стороны
                      Text(
                        'Левая сторона',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondryColor,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextField(
                        controller: _controllerLeftA,
                        decoration: InputDecoration(
                          labelText: 'Расстояние A',
                          labelStyle: TextStyle(color: AppColors.secondryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextField(
                        controller: _controllerLeftB,
                        decoration: InputDecoration(
                          labelText: 'Расстояние B',
                          labelStyle: TextStyle(color: AppColors.secondryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Блок для правой стороны
                      Text(
                        'Правая сторона',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondryColor,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextField(
                        controller: _controllerRightA,
                        decoration: InputDecoration(
                          labelText: 'Расстояние A',
                          labelStyle: TextStyle(color: AppColors.secondryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TextField(
                        controller: _controllerRightB,
                        decoration: InputDecoration(
                          labelText: 'Расстояние B',
                          labelStyle: TextStyle(color: AppColors.secondryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      // Кнопка для расчета
                      ElevatedButton(
                        onPressed: _calculateIndexes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.08),
                          ),
                        ),
                        child: Text(
                          AppStrings.buttonCalculateString,
                          style: TextStyle(
                            color: AppColors.thirdColor,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Отображение результатов (если расчёт произведён)
                      if (_leftIndex != null && _rightIndex != null) ...[
                        ResultCard(
                          text:
                          'Индекс Реймерса (Левая сторона): ${_leftIndex!.toStringAsFixed(1)}%\n\nРекомендация: $_leftRecommendation',
                        ),
                        SizedBox(height: screenHeight * 0.003),
                        ResultCard(
                          text:
                          'Индекс Реймерса (Правая сторона): ${_rightIndex!.toStringAsFixed(1)}%\n\nРекомендация: $_rightRecommendation',
                        ),
                      ],

                      SizedBox(height: screenHeight * 0.025),

                      // Кнопка "Далее"
                      GestureDetector(
                        onTap: _onNextPressed,
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
                      SizedBox(height: screenHeight * 0.02),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScrenningPageReym(
                                tempStorage: widget.tempStorage, // Передайте экземпляр TempStorage
                              ),
                            ),
                          );
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
                              AppStrings.buttonScreen4String,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Остальные элементы страницы (например, справка)
                      GestureDetector(
                        onTap: () {
                          int index = 4;
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
                      SizedBox(height: screenHeight * 0.02),
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

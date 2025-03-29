import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neuro_pro/osnova/about_program.dart';
import '../../assets/data/texts/strings.dart';
import '../../osnova/screensMainSkills/manual_skills_app.dart';
import '../../widgets/FirstLaunchDialog.dart';
import '../screnning/ScrenningPage.dart';
import '../../osnova/manual_screen.dart';
import '../diagnostics/diagnostic_page1.dart';
import '../../services/temp_storage.dart';
import '../../assets/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для работы с SharedPreferences

class HomeScreen extends StatelessWidget {
  final TempStorage tempStorage;

  HomeScreen({Key? key, TempStorage? tempStorage})
      : tempStorage = tempStorage ?? TempStorage(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;
          final double buttonSize = screenWidth * 0.4;
          final double buttonSpacing = screenHeight * 0.05;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                color: AppColors.thirdColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.nameAppString,
                      style: TextStyle(
                        color: AppColors.secondryColor,
                        fontFamily: 'TinosBold',
                        fontSize: screenWidth * 0.10,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: buttonSpacing),
                    // Первая строка кнопок
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          context,
                          AppStrings.buttonStartDiagnosticString,
                          'lib/assets/svg/diagnostic_icon.svg',
                          buttonSize,
                          onPressed: () {
                            final diagnosticType1 = tempStorage.getData('screen.distanceA');
                            final diagnosticType2 = tempStorage.getData('screen.distanceB');
                            final diagnosticType3 = tempStorage.getData('screen.reymers');
                            debugPrint('\n\n\n\nA: $diagnosticType1');
                            debugPrint('B: $diagnosticType2');
                            debugPrint('Reym: $diagnosticType3 \n\n\n\n');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiagnosticPage1(
                                  currentStep: 1,
                                  tempStorage: tempStorage,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildButton(
                          context,
                          AppStrings.buttonStartScreenningString,
                          'lib/assets/svg/xray_icon.svg',
                          buttonSize,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScrenningPage(
                                  tempStorage: tempStorage,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: buttonSpacing),
                    // Вторая строка кнопок
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          context,
                          AppStrings.buttonStartManualString,
                          'lib/assets/svg/manual_icon.svg',
                          buttonSize,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManualScreen(tempStorage: tempStorage),
                              ),
                            );
                          },
                        ),
                        _buildOutlinedButton(
                          context,
                          AppStrings.buttonStartAboutString,
                          'lib/assets/svg/about_icon.svg',
                          buttonSize,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutProgram(tempStorage: tempStorage),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Проверка первого запуска
                    FutureBuilder(
                      future: _checkFirstLaunch(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data == true) {
                          // Показать диалоговое окно, если первый запуск
                          Future.delayed(Duration.zero, () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FirstLaunchDialog(
                                  onLearnMorePressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ManualSkillsApp(),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          });
                        }
                        return Container(); // Возвращаем пустой контейнер, пока ждем данные
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String title,
      String iconPath,
      double size, {
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: size * 0.4,
              height: size * 0.4,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.thirdColor,
                fontSize: size * 0.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
      BuildContext context,
      String title,
      String iconPath,
      double size, {
        required VoidCallback onPressed,
      }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.thirdColor,
          border: Border.all(
            width: 2.0,
            color: AppColors.secondryColor,
          ),
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: size * 0.4,
              height: size * 0.4,
              color: AppColors.secondryColor,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondryColor,
                fontSize: size * 0.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Проверяем, был ли это первый запуск
  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
    if (isFirstLaunch == null || isFirstLaunch) {
      return true;
    }
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для загрузки JSON из assets
import 'package:neuro_pro/osnova/screensAutors/autors_screen.dart';
import 'package:neuro_pro/osnova/screensMainSkills/manual_skills_app.dart';
import '../assets/colors/app_colors.dart';
import '../assets/data/texts/strings.dart';
import 'screensTopic/topic_detail_screen.dart';
import '../services/temp_storage.dart';

class AboutProgram extends StatefulWidget {
  final TempStorage tempStorage;

  const AboutProgram({Key? key, required this.tempStorage}) : super(key: key);

  @override
  _AboutProgramState createState() => _AboutProgramState();
}

class _AboutProgramState extends State<AboutProgram> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.thirdColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(
            color: AppColors.thirdColor
        ),
        title: const Text(
          AppStrings.buttonStartAboutString,
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'TinosBold', color: AppColors.thirdColor)
        ),
      ),
      body: SingleChildScrollView( // Сделаем страницу прокручиваемой
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Заголовок программы
            Text(
              AppStrings.nameAppString,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondryColor,
                fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                fontFamily: 'TinosBold',
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Версия программы
            Text(
              AppStrings.versionString,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Описание программы
            Text(
              AppStrings.textDecriptionAboutString,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.text2Color,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // Кнопки и их разделители
            _buildButton(AppStrings.buttonAutorsAboutString, Icons.person, screenHeight, screenWidth, AuthorsScreen()),
            _buildButton(AppStrings.buttonOsnAboutString, Icons.format_list_bulleted_sharp, screenHeight, screenWidth, ManualSkillsApp()),
            _buildButton(AppStrings.buttonOptionsAboutString, Icons.bubble_chart_rounded, screenHeight, screenWidth, null),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, double screenHeight, double screenWidth, Widget? destinationScreen) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          leading: Icon(icon, color: AppColors.primaryColor),
          title: Text(
            text,
            style: TextStyle(
              color: AppColors.secondryColor,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: AppColors.secondryColor),
          onTap: () {
            if (destinationScreen != null) {
              // Переход на новый экран, если destinationScreen не null
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationScreen),
              );
            } else {
              // Ошибка: Возраст вне диапазона
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Настройки появятся в следующих обновлениях!'),
                  backgroundColor: AppColors.errorColor,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        Divider(
          color: Colors.blueGrey, // Цвет линии
          thickness: 0.5,
          indent: 15, // Отступ слева
          endIndent: 15, // Отступ справа
        ),
      ],
    );
  }
}

import 'dart:convert'; // Для работы с JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для загрузки JSON из assets
import 'package:neuro_pro/assets/colors/app_colors.dart';
import 'package:neuro_pro/services/model_spravka_helper.dart';
import 'package:neuro_pro/services/spravka_service.dart';
import 'package:neuro_pro/osnova/screensTopic/topic_detail_screen.dart';

import '../osnova/screensMainSkills/topic_detail_skills.dart'; // Импорт экрана с деталями темы

class SpravkaDialog extends StatelessWidget {
  final int index;
  final int? id; // Сделали id nullable

  const SpravkaDialog({required this.index, this.id}); // Убрали required у id

  Future<List<dynamic>> loadTopics() async {
    final String response = await rootBundle.loadString('lib/assets/data/json/topics.json');
    final Map<String, dynamic> data = json.decode(response);
    return data['topics'];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Spravka>>(
      future: SpravkaService().loadSpravki(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки справки'));
        }

        if (snapshot.hasData) {
          var spravka = snapshot.data![index];
          return Dialog(
            backgroundColor: AppColors.thirdColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.01),
              width: screenWidth * 0.9,
              height: screenHeight * 0.75,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              spravka.title,
                              style: TextStyle(
                                color: AppColors.mainTitleColor,
                                fontSize: screenWidth * 0.08,
                                fontFamily: 'TinosBold',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ...spravka.content.map((content) {
                            if (content.type == 'tit') {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                                child: Text(
                                  content.text ?? '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.secondryColor,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            } else if (content.type == 'text') {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                                child: Text(
                                  content.text ?? '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.text2Color,
                                    fontSize: screenWidth * 0.037,
                                    height: 1.15,
                                  ),
                                ),
                              );
                            } else if (content.type == 'image') {
                              return Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 4.0,
                                            child: Image.asset(
                                              content.imagePath ?? '',
                                              fit: BoxFit.contain,
                                              height: 500,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.asset(
                                    content.imagePath ?? '',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            } else if (content.type == 'important') {
                              // Новый тип для жирного красного текста
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                                child: Text(
                                  content.text ?? '',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.037,
                                    height: 1.15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return Container();
                          }).toList(),
                          SizedBox(height: screenHeight * 0.02),
                          // Проверяем, передан ли id, если нет — кнопку не отображаем
                          if (id != null)
                            GestureDetector(
                              onTap: () async {
                                var topics = await loadTopics();
                                var selectedTopic = topics[id!]; // id точно не null
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TopicDetailScreen(
                                      title: selectedTopic['title'],
                                      content: selectedTopic['content'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: screenWidth * 0.8,
                                height: screenHeight * 0.07,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    'Открыть справочник',
                                    style: TextStyle(
                                      color: Colors.white,
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
                  Positioned(
                    right: screenWidth * 0.02,
                    top: screenHeight * 0.02,
                    child: IconButton(
                      icon: Icon(Icons.cancel_outlined, color: AppColors.text1Color),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Center(child: Text('Нет данных для отображения.'));
      },
    );
  }
}


class SpravkaDialog2 extends StatelessWidget {
  final int id;

  const SpravkaDialog2({required this.id});

  Future<List<dynamic>> loadTopics() async {
    final String response = await rootBundle.loadString('lib/assets/data/json/skills_app.json');
    final Map<String, dynamic> data = json.decode(response);
    return data['topics'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: loadTopics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Показываем индикатор загрузки
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки справочника')); // Если ошибка при загрузке
        }

        if (snapshot.hasData) {
          var topics = snapshot.data!;
          var selectedTopic = topics[id]; // Получаем выбранную тему

          // Переход сразу, без показа чего-либо на текущем экране
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TopicDetailSkills(
                  title: selectedTopic['title'],
                  content: selectedTopic['content'],
                ),
              ),
            );
          });

          return SizedBox.shrink(); // Не показываем ничего
        }

        return Container(); // Нет данных — не показываем ничего
      },
    );
  }
}





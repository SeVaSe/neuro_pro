import 'dart:convert'; // Для работы с JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для загрузки JSON из assets
import 'package:neuro_pro/assets/data/texts/strings.dart';
import 'screensTopic/topic_detail_screen.dart';
import '../services/temp_storage.dart';
import '../assets/colors/app_colors.dart';

class ManualScreen extends StatefulWidget {
  final TempStorage tempStorage; // Добавьте TempStorage как параметр конструктора

  const ManualScreen({Key? key, required this.tempStorage}) : super(key: key); // Обновите конструктор

  @override
  _ManualScreenState createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  List<dynamic> topics = []; // Список тем из JSON
  List<dynamic> filteredTopics = []; // Отфильтрованные темы для поиска
  final TextEditingController searchController = TextEditingController(); // Контроллер для строки поиска

  late String? patientAge;

  @override
  void initState() {
    super.initState();
    patientAge = widget.tempStorage.getData('patient.age'); // Теперь можно использовать tempStorage
    debugPrint('\n\n\n\n ПРОВЕРКА тип: $patientAge \n\n\n\n');
    loadTopics(); // Загружаем данные из JSON
    searchController.addListener(() {
      filterTopics(); // Обновляем фильтр при изменении текста в строке поиска
    });
  }

  // Загрузка JSON из assets
  Future<void> loadTopics() async {
    final String response = await rootBundle.loadString('lib/assets/data/json/topics.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      topics = data['topics'];
      filteredTopics = topics; // Изначально отображаем все темы
    });
  }

  // Фильтрация тем по названию
  void filterTopics() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredTopics = topics
          .where((topic) => topic['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(
            color: AppColors.thirdColor
        ),
        title: const Text(
          AppStrings.buttonStartManualString,
          style: TextStyle(
              fontFamily: 'TinosBold',
              fontWeight: FontWeight.bold,
              color: AppColors.thirdColor
          ),
        ),
      ),
      body: Column(
        children: [
          // Строка поиска
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по названию темы...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.secondryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.thirdColor,
              ),
            ),
          ),
          // Список тем
          Expanded(
            child: ListView.builder(
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicDetailScreen(
                              title: topic['title'],
                              content: topic['content'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: Text(
                          topic['title'],
                          style: const TextStyle(
                            color: AppColors.thirdColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

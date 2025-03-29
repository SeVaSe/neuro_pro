import 'package:flutter/material.dart';
import '../../assets/colors/app_colors.dart';

class TopicDetailSkills extends StatelessWidget {
  final String title; // Название темы
  final List<dynamic> content; // Содержимое темы

  const TopicDetailSkills({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.thirdColor),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'TinosBold',
            fontWeight: FontWeight.bold,
            color: AppColors.thirdColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: content.length,
          itemBuilder: (context, index) {
            final section = content[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['sectionTitle'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'TinosBold',
                      color: AppColors.secondryColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    section['text'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.text2Color,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Проверяем, есть ли изображение
                  if (section['image'] != null)
                    GestureDetector(
                      onTap: () {
                        _showImageDialog(context, section['image']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: AppColors.primaryColor.withOpacity(0.3), // Фон для рамки
                          boxShadow: [
                            // Внутренняя тень для эффекта глубины
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              spreadRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3), // Отступ для белой рамки
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            section['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),

                  const Divider(height: 20, color: Colors.grey),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true, // Разрешает перемещение
                boundaryMargin: const EdgeInsets.all(20), // Отступы
                minScale: 1.0, // Минимальный масштаб
                maxScale: 4.0, // Можно увеличивать до 4x
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

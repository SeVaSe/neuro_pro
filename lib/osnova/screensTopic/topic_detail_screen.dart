import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../assets/colors/app_colors.dart';

class TopicDetailScreen extends StatelessWidget {
  final String title;
  final List<dynamic> content; // Массив объектов с различными типами контента

  const TopicDetailScreen({
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
      body: content.isNotEmpty ? _buildContent(context) : const Center(child: Text("Контент не найден")),
    );
  }

  Widget _buildContent(BuildContext context) {
    final firstContent = content[0];

    if (firstContent.containsKey('pathPDF')) {
      // Если есть PDF, отображаем его
      return SfPdfViewer.asset(
        firstContent['pathPDF'],
        canShowScrollHead: true,
        canShowScrollStatus: true,
      );
    } else {
      return _buildTextContent(context);
    }
  }

  Widget _buildTextContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map<Widget>((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Отображаем возрастную группу, если есть
              if (item.containsKey('ageGroup') && item['ageGroup'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    item['ageGroup'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

              // Отображаем уровни внутри возрастной группы
              if (item.containsKey('levels') && item['levels'] is List)
                ...List<Widget>.from(item['levels'].map<Widget>((levelItem) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (levelItem.containsKey('level') && levelItem['level'] != null)
                          Text(
                            levelItem['level'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        if (levelItem.containsKey('text') && levelItem['text'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              levelItem['text'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                })),

              // Отображаем текст, если есть (для совместимости со старым форматом)
              if (item.containsKey('text') && item['text'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    item['text'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),

              // Отображаем изображение, если есть
              if (item.containsKey('imagePath') && item['imagePath'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      _showImageDialog(context, item['imagePath']);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        item['imagePath'],
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Изображение не найдено',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Отображаем заголовок, если есть
              if (item.containsKey('subtitle') && item['subtitle'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                  child: Text(
                    item['subtitle'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Показывает диалог с увеличенным изображением
  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Изображение не найдено',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
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

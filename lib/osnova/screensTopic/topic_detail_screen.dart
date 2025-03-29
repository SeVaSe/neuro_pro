import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../assets/colors/app_colors.dart';

/// Экран с подробностями темы, который сразу открывает PDF.
/// Предполагается, что в content содержится хотя бы один элемент с ключом "pathPDF".
class TopicDetailScreen extends StatelessWidget {
  final String title;
  final List<dynamic> content; // Массив объектов с ключом "pathPDF"

  const TopicDetailScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Предположим, что мы всегда открываем первый PDF из массива.
    final pdfPath = content.isNotEmpty ? content[0]['pathPDF'] : null;

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
      body: pdfPath != null
          ? SfPdfViewer.asset(
        pdfPath,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      )
          : const Center(child: Text("PDF не найден")),
    );
  }
}

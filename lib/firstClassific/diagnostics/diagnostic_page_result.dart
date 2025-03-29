import 'dart:io';
import 'package:flutter/material.dart';
import 'package:neuro_pro/assets/data/texts/strings.dart';
import 'package:neuro_pro/firstClassific/basic/home_screen.dart';
import 'package:neuro_pro/services/temp_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../assets/colors/app_colors.dart';
import '../../services/logger.dart';
import '../../widgets/CustomDialogExit.dart';
import 'package:flutter/services.dart' show rootBundle;

class DiagnosticPageResult extends StatelessWidget {
  final int currentStep;
  final TempStorage tempStorage;

  const DiagnosticPageResult({
    Key? key,
    required this.currentStep,
    required this.tempStorage,
  }) : super(key: key);

  void _generateAndSharePdf(BuildContext context, TempStorage tempStorage) async {
    try {
      // 1. Загружаем шрифты
      final fontData =
      await rootBundle.load('lib/assets/fonts/Montserrat-Regular.ttf');
      final fontDataB =
      await rootBundle.load('lib/assets/fonts/Montserrat-Bold.ttf');
      final ttf = pw.Font.ttf(fontData);
      final ttfB = pw.Font.ttf(fontDataB);

      // 2. Создаём документ PDF
      final pdf = pw.Document();

      final Map<String, String> cardsData = {
        'Тип ДЦП': 'diagnostic1.type',
        'Возраст пациента': 'diagnostic2.age',
        'Уровень GMFCS': 'diagnostic3.gmfcs',
        'Частота рентгена': 'diagnostic4.xray',
        'Индекс Реймерса': 'diagnostic5.reimers',
        'Денситометрия': 'diagnostic6.densimetr',
        'Эндокринолог': 'diagnostic6.endocrin',
        'Ботулинотерапия': 'diagnostic7.buto',
        'Описание походки': 'diagnostic8.descriptionvideo',
        'Ортезы': 'diagnostic9.ortez',
      };

      // 3. Добавляем страницу с многостраничной разбивкой
      pdf.addPage(
        pw.MultiPage(
          // Настройка темы страницы
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            // Можно задать формат, если нужно (A4, Letter и т.д.)
            // pageFormat: PdfPageFormat.a4,
          ),

          // Заголовок на каждой странице (header)
          header: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NeuroOrto.pro',
                  style: pw.TextStyle(
                    font: ttfB,
                    fontSize: 24,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Официальный медицинский документ',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                  ),
                ),
                pw.Divider(height: 15, thickness: 1),
              ],
            );
          },

          // Футер на каждой странице (footer)
          footer: (pw.Context context) {
            // Номер текущей страницы / общее кол-во
            final pageNumber = context.pageNumber;
            final totalPages = context.pagesCount;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Divider(height: 15, thickness: 1),
                pw.Text(
                  'Страница $pageNumber/$totalPages',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },

          build: (pw.Context context) {
            return [
              // 4. Заголовок блока "Данные пациента"
              pw.Text(
                'Данные пациента',
                style: pw.TextStyle(
                  font: ttfB,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 10),

              // 5. Таблица с данными
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(3),
                },
                children: cardsData.entries.map((entry) {
                  final title = entry.key;
                  final key = entry.value;
                  final value =
                      tempStorage.getData(key)?.toString() ?? 'Данные отсутствуют';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          title,
                          style: pw.TextStyle(
                            font: ttfB,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          value,
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 20),

              // 6. Доп. инфо: дата, подпись и т.д.
              pw.Text(
                'Дата: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Подпись врача:',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(height: 1, thickness: 1),
            ];
          },
        ),
      );

      // 7. Сохранение PDF в файл
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/patient_statistics.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // 8. Отправка через системное окно
      final xFile = XFile(filePath);
      final result = await Share.shareXFiles(
        [xFile],
        text: 'Данные пациента в PDF',
      );

      if (result.status == ShareResultStatus.success) {
        debugPrint('PDF успешно отправлен!');
      } else if (result.status == ShareResultStatus.dismissed) {
        debugPrint('Отправка PDF отменена.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при создании или отправке PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Названия карточек и ключи для данных
    final Map<String, String> cardsData = {
      'ТИП ДЦП': 'diagnostic1.type',
      'ВОЗРАСТ ПАЦИЕНТА': 'diagnostic2.age',
      'УРОВЕНЬ GMFCS': 'diagnostic3.gmfcs',
      'ЧАСТОТА РЕНТГЕНА': 'diagnostic4.xray',
      'ИНДЕКС РЕЙМЕРСА': 'diagnostic5.reimers',
      'ДЕНСИТОМЕТРИЯ': 'diagnostic6.densimetr',
      'ЭНДОКРИНОЛОГ': 'diagnostic6.endocrin',
      'БОТУЛИНОТЕРАПИЯ': 'diagnostic7.buto',
      'ОПИСАНИЕ ПОХОДКИ': 'diagnostic8.descriptionvideo',
      'ОРТЕЗЫ': 'diagnostic9.ortez',
    };

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false; // Возвращает true, если пользователь подтвердил выход
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Основное содержимое
            Positioned.fill(
              top: screenHeight * 0.05, // Отступ сверху
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Заголовок
                    Text(
                      'Данные пациента',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondryColor,
                        fontSize: screenWidth * 0.10, // Адаптируемый размер шрифта
                        fontFamily: 'TinosBold',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Секция карточек
                    Expanded(
                      child: ListView.builder(
                        itemCount: cardsData.length,
                        itemBuilder: (context, index) {
                          final title = cardsData.keys.elementAt(index);
                          final key = cardsData[title]!;
                          final description = tempStorage.getData(key) == ""
                              ? 'Описание не указано'
                              : (tempStorage.getData(key) ?? 'Данные отсутствуют');

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.secondryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Заголовок карточки
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: AppColors.thirdColor,
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'TinosBold',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Описание
                                Text(
                                  description.toString(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Кнопки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _generateAndSharePdf(context, tempStorage);
                            print("Полученные данные: ${tempStorage.getAllData()}");
                          },
                          child: Container(
                            width: screenWidth * 0.35,
                            height: screenHeight * 0.06,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf,
                                    color: AppColors.thirdColor),
                                const SizedBox(width: 5),
                                Text(
                                  AppStrings.buttonPDFString,
                                  style: TextStyle(
                                    color: AppColors.thirdColor,
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            tempStorage.clearAllData();
                            DiagnosticLogger.logDiagnostic(
                              'Проверка очистки хранилища',
                              'diagnostic2.age',
                              tempStorage,
                            );

                            // Переход на следующий экран
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.35,
                            height: screenHeight * 0.06,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_sharp,
                                    color: AppColors.thirdColor),
                                const SizedBox(width: 5),
                                Text(
                                  AppStrings.buttonDestroyString,
                                  style: TextStyle(
                                    color: AppColors.thirdColor,
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

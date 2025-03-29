import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Для загрузки изображения
import 'dart:io'; // Для работы с файлами
import 'package:flutter/services.dart'; // Для управления ориентацией экрана
import 'package:neuro_pro/assets/data/texts/strings.dart';
import 'package:neuro_pro/widgets/CustomHelpScreen.dart';

import '../../services/temp_storage.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../assets/colors/app_colors.dart';
import '../../widgets/CustomResultCard.dart';
import '../diagnostics/diagnostic_page5.dart';

class ScrenningPageReym extends StatefulWidget {
  final TempStorage tempStorage; // Хранилище данных

  const ScrenningPageReym({Key? key, required this.tempStorage}) : super(key: key);

  @override
  _ScrenningPageReymState createState() => _ScrenningPageReymState();
}

class _ScrenningPageReymState extends State<ScrenningPageReym> {
  File? _image; // Переменная для хранения изображения
  final ImagePicker _picker = ImagePicker(); // Инициализация ImagePicker
  bool _isEditing = false; // Флаг для режима редактирования
  bool _isIndexPanelVisible = false; // Флаг для показа панели с измерениями
  bool _isGridEnabled = false; // Флаг для включения/выключения сетки

  // Флаг для выбора активного сустава: true — левый, false — правый
  bool _isLeftActive = true;

  // Переменные для левого сустава
  Offset? _leftPointA1; // Первая точка A левого сустава
  Offset? _leftPointA2; // Вторая точка A левого сустава
  double? _leftDistanceA; // Расстояние для A левого сустава
  Offset? _leftPointB1; // Первая точка B левого сустава
  Offset? _leftPointB2; // Вторая точка B левого сустава
  double? _leftDistanceB; // Расстояние для B левого сустава
  double? _leftIndex; // ИМ для левого сустава

  // Переменные для правого сустава
  Offset? _rightPointA1; // Первая точка A правого сустава
  Offset? _rightPointA2; // Вторая точка A правого сустава
  double? _rightDistanceA; // Расстояние для A правого сустава
  Offset? _rightPointB1; // Первая точка B правого сустава
  Offset? _rightPointB2; // Вторая точка B правого сустава
  double? _rightDistanceB; // Расстояние для B правого сустава
  double? _rightIndex; // ИМ для правого сустава

  // Флаг отображения лупы
  bool _showMagnifier = false;
// Позиция пальца для лупы
  Offset _magnifierPosition = Offset.zero;


  // Угол поворота изображения
  double _imageRotation = 0.0;

  // Метод для загрузки изображения или съёмки с камеры
  Future<void> _pickImage(bool fromCamera) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageRotation = 0.0; // Сброс угла при загрузке нового изображения
        _isEditing = false; // Выход из режима редактирования при новом изображении
      });
    }
  }

  // Метод для построения виджета лупы
  Widget _buildMagnifier(double screenWidth, double screenHeight) {
    const double magnifierSize = 120;
    const double offsetAbove = 80;
    // Положение центра лупы на экране (отодвинуто вверх от положения пальца)
    final magnifierCenterOnScreen = _magnifierPosition - Offset(0, offsetAbove);
    return Positioned(
      left: magnifierCenterOnScreen.dx - magnifierSize / 2,
      top: magnifierCenterOnScreen.dy - magnifierSize / 2,
      child: ClipOval(
        child: Container(
          width: magnifierSize,
          height: magnifierSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.7), width: 2),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              // Прицел (крестик)
              Center(
                child: Icon(Icons.add, color: Colors.red.withOpacity(0.9), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGrid(double screenWidth, double screenHeight) {
    const double gridSpacing = 45.0;
    List<Widget> lines = [];

    // Вертикальные линии
    for (double x = 0; x < screenWidth; x += gridSpacing) {
      lines.add(Positioned(
        left: x,
        top: 0,
        child: Container(
          width: 1.2,
          height: screenHeight,
          color: AppColors.primaryColor.withOpacity(0.6),
        ),
      ));
    }

    // Горизонтальные линии
    for (double y = 0; y < screenHeight; y += gridSpacing) {
      lines.add(Positioned(
        left: 0,
        top: y,
        child: Container(
          width: screenWidth,
          height: 1.2,
          color: AppColors.primaryColor.withOpacity(0.6),
        ),
      ));
    }

    return Stack(children: lines);
  }

  double _calculateDistance(Offset point1, Offset point2) {
    return (point2.dx - point1.dx).abs() + (point2.dy - point1.dy).abs();
  }

  void _calculateLeftIndex() {
    if (_leftDistanceA != null && _leftDistanceB != null && _leftDistanceB != 0) {
      setState(() {
        _leftIndex = (_leftDistanceA! / _leftDistanceB!) * 100;
      });
    }
  }

  void _calculateRightIndex() {
    if (_rightDistanceA != null && _rightDistanceB != null && _rightDistanceB != 0) {
      setState(() {
        _rightIndex = (_rightDistanceA! / _rightDistanceB!) * 100;
      });
    }
  }

  // Метод выбора точек для активного сустава
  void _selectPoint(Offset position) {
    if (_isLeftActive) {
      if (_leftPointA1 == null) {
        setState(() {
          _leftPointA1 = position;
        });
      } else if (_leftPointA2 == null) {
        setState(() {
          _leftPointA2 = position;
          _leftDistanceA = _calculateDistance(_leftPointA1!, _leftPointA2!);
        });
      } else if (_leftPointB1 == null) {
        setState(() {
          _leftPointB1 = position;
        });
      } else if (_leftPointB2 == null) {
        setState(() {
          _leftPointB2 = position;
          _leftDistanceB = _calculateDistance(_leftPointB1!, _leftPointB2!);
        });
      }
      _calculateLeftIndex();
    } else {
      if (_rightPointA1 == null) {
        setState(() {
          _rightPointA1 = position;
        });
      } else if (_rightPointA2 == null) {
        setState(() {
          _rightPointA2 = position;
          _rightDistanceA = _calculateDistance(_rightPointA1!, _rightPointA2!);
        });
      } else if (_rightPointB1 == null) {
        setState(() {
          _rightPointB1 = position;
        });
      } else if (_rightPointB2 == null) {
        setState(() {
          _rightPointB2 = position;
          _rightDistanceB = _calculateDistance(_rightPointB1!, _rightPointB2!);
        });
      }
      _calculateRightIndex();
    }
  }

  // Функция для поворота изображения
  void _rotateImage(double angle) {
    setState(() {
      _imageRotation += angle;
    });
  }

  // Функция для сохранения изображения (выход из режима редактирования)
  void _saveImage() {
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Устанавливаем горизонтальную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  @override
  void dispose() {
    // Возвращаем портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth  = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double controlPanelHeight = 60.0;
    final double availableHeight = screenHeight - controlPanelHeight;
    final double stripHeight = availableHeight / 5;

    // Размер шрифта и отступы для адаптивности
    final double fontSize = screenHeight * 0.04;
    final double horizontalSpacing = screenWidth * 0.02;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationTempReymDialog(context, widget.tempStorage);
        return exit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        body: Stack(
          children: [
            // Изображение с возможностью масштабирования
            if (_image != null)
              GestureDetector(
                onTapUp: (details) {
                  _selectPoint(details.localPosition);
                },
                // При длительном нажатии показываем лупу
                onLongPressStart: (details) {
                  setState(() {
                    _showMagnifier = true;
                    _magnifierPosition = details.localPosition;
                  });
                },
                onLongPressMoveUpdate: (details) {
                  setState(() {
                    _magnifierPosition = details.localPosition;
                  });
                },
// При отпускании, точка ставится в центре лупы
                onLongPressEnd: (details) {
                  setState(() {
                    // Центр лупы смещён вверх на 80 пикселей от позиции пальца
                    final selectedPoint = _magnifierPosition - Offset(0, 80);
                    _selectPoint(selectedPoint);
                    _showMagnifier = false;
                  });
                },
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.all(50),
                  minScale: 0.1,
                  maxScale: 100.0,
                  child: Transform.rotate(
                    angle: _imageRotation,
                    child: Image.file(
                      _image!,
                      width: screenWidth,
                      height: screenHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'Изображение не выбрано',
                  style: TextStyle(fontSize: fontSize, color: Colors.grey),
                ),
              ),

            //-------------------------------------------------------------
            // ПАНЕЛЬ (ОБЫЧНЫЙ РЕЖИМ)
            //-------------------------------------------------------------
            if (!_isIndexPanelVisible && !_isEditing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: controlPanelHeight,
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: horizontalSpacing),
                          // Галерея
                          TextButton(
                            onPressed: () => _pickImage(false),
                            child: Text(
                              AppStrings.buttonGaleryScreeningString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Камера
                          TextButton(
                            onPressed: () => _pickImage(true),
                            child: Text(
                              AppStrings.buttonCameraScreeningString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Режим редактирования
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            child: Text(
                              AppStrings.buttonChangeScreeningString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Переход к измерениям
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isIndexPanelVisible = true;
                              });
                            },
                            child: Text(
                              AppStrings.buttonIndexScreeningString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),

                          SizedBox(width: horizontalSpacing),
                          // Переход к справке
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SpravkaDialog2(id: 2))
                              );
                            },
                            child: Text(
                              "Справка",
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),

                          SizedBox(width: horizontalSpacing),
                          // Кнопка
                          TextButton(
                            onPressed: () async {
                              final exit = await showExitConfirmationTempReymDialog2(context, widget.tempStorage);

                              if (exit ?? false) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => DiagnosticPage5(
                                    currentStep: 5, // Передаем номер текущего шага
                                    tempStorage: widget.tempStorage, // Передаем хранилище данных
                                  ),),
                                      (route) => false,
                                );
                              }
                            },
                            child: Text(
                              'Выйти',
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            //-------------------------------------------------------------
            // ПАНЕЛЬ (РЕЖИМ ИЗМЕРЕНИЙ)
            //-------------------------------------------------------------
            if (_isIndexPanelVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: controlPanelHeight,
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: horizontalSpacing),
                          // Переключатель: левый сустав
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLeftActive = true;
                              });
                            },
                            child: Text(
                              'Левый сустав',
                              style: TextStyle(
                                color: _isLeftActive
                                    ? AppColors.thirdColor
                                    : AppColors.thirdColor.withOpacity(0.3),
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Переключатель: правый сустав
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLeftActive = false;
                              });
                            },
                            child: Text(
                              'Правый сустав',
                              style: TextStyle(
                                color: !_isLeftActive
                                    ? AppColors.thirdColor
                                    : AppColors.thirdColor.withOpacity(0.3),
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Кнопка сохранения результатов
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isIndexPanelVisible = false;
                                _isGridEnabled = false;

                                // Форматирование и сохранение для левого сустава
                                String leftDistanceA =
                                (_leftDistanceA ?? 0).toStringAsFixed(2);
                                String leftDistanceB =
                                (_leftDistanceB ?? 0).toStringAsFixed(2);
                                String leftIndex =
                                (_leftIndex ?? 0).toStringAsFixed(2);

                                // Форматирование и сохранение для правого сустава
                                String rightDistanceA =
                                (_rightDistanceA ?? 0).toStringAsFixed(2);
                                String rightDistanceB =
                                (_rightDistanceB ?? 0).toStringAsFixed(2);
                                String rightIndex =
                                (_rightIndex ?? 0).toStringAsFixed(2);

                                widget.tempStorage.saveData(
                                    "screen.left.distanceA", leftDistanceA);
                                widget.tempStorage.saveData(
                                    "screen.left.distanceB", leftDistanceB);
                                widget.tempStorage.saveData(
                                    "screen.left.index", leftIndex);

                                widget.tempStorage.saveData(
                                    "screen.right.distanceA", rightDistanceA);
                                widget.tempStorage.saveData(
                                    "screen.right.distanceB", rightDistanceB);
                                widget.tempStorage.saveData(
                                    "screen.right.index", rightIndex);

                                // Сброс всех параметров
                                _leftPointA1 = null;
                                _leftPointA2 = null;
                                _leftDistanceA = null;
                                _leftPointB1 = null;
                                _leftPointB2 = null;
                                _leftDistanceB = null;
                                _leftIndex = null;

                                _rightPointA1 = null;
                                _rightPointA2 = null;
                                _rightDistanceA = null;
                                _rightPointB1 = null;
                                _rightPointB2 = null;
                                _rightDistanceB = null;
                                _rightIndex = null;
                              });
                            },
                            child: Text(
                              AppStrings.buttonSaveScreeningString,
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Очистка точек A для активного сустава
                          TextButton(
                            onPressed: () {
                              if (_isLeftActive) {
                                setState(() {
                                  _leftPointA1 = null;
                                  _leftPointA2 = null;
                                  _leftDistanceA = null;
                                  _leftIndex = null;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Точки очищены для A левого сустава',
                                        style: TextStyle(
                                          color: AppColors.secondryColor,
                                          fontFamily: 'TinosBold',
                                        ),
                                      ),
                                      content: Text(
                                        'Выберите точки для A левого сустава',
                                        style:
                                        TextStyle(color: AppColors.text2Color),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Закрыть',
                                            style: TextStyle(
                                              color: AppColors.text1Color,
                                              fontFamily: 'TinosBold',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  _rightPointA1 = null;
                                  _rightPointA2 = null;
                                  _rightDistanceA = null;
                                  _rightIndex = null;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Точки очищены для A правого сустава',
                                        style: TextStyle(
                                          color: AppColors.secondryColor,
                                          fontFamily: 'TinosBold',
                                        ),
                                      ),
                                      content: Text(
                                        'Выберите точки для A правого сустава',
                                        style:
                                        TextStyle(color: AppColors.text2Color),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Закрыть',
                                            style: TextStyle(
                                              color: AppColors.text1Color,
                                              fontFamily: 'TinosBold',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Очистка точек B для активного сустава
                          TextButton(
                            onPressed: () {
                              if (_isLeftActive) {
                                setState(() {
                                  _leftPointB1 = null;
                                  _leftPointB2 = null;
                                  _leftDistanceB = null;
                                  _leftIndex = null;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Точки очищены для B левого сустава',
                                        style: TextStyle(
                                          color: AppColors.secondryColor,
                                          fontFamily: 'TinosBold',
                                        ),
                                      ),
                                      content: Text(
                                        'Выберите точки для B левого сустава',
                                        style:
                                        TextStyle(color: AppColors.text2Color),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Закрыть',
                                            style: TextStyle(
                                              color: AppColors.text1Color,
                                              fontFamily: 'TinosBold',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  _rightPointB1 = null;
                                  _rightPointB2 = null;
                                  _rightDistanceB = null;
                                  _rightIndex = null;
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Точки очищены для B правого сустава',
                                        style: TextStyle(
                                          color: AppColors.secondryColor,
                                          fontFamily: 'TinosBold',
                                        ),
                                      ),
                                      content: Text(
                                        'Выберите точки для B правого сустава',
                                        style:
                                        TextStyle(color: AppColors.text2Color),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Закрыть',
                                            style: TextStyle(
                                              color: AppColors.text1Color,
                                              fontFamily: 'TinosBold',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(
                              'B',
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          // Переключение отображения сетки
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isGridEnabled = !_isGridEnabled;
                              });
                            },
                            child: Text(
                              'Сетка',
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            //-------------------------------------------------------------
            // ПАНЕЛЬ (РЕЖИМ РЕДАКТИРОВАНИЯ)
            //-------------------------------------------------------------
            if (_isEditing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: controlPanelHeight,
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: horizontalSpacing),
                          TextButton(
                            onPressed: _saveImage,
                            child: Text(
                              AppStrings.buttonSaveScreeningString,
                              style: TextStyle(color: AppColors.thirdColor, fontSize: fontSize),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                          TextButton(
                            onPressed: () => _rotateImage(-1.0 * 3.14159 / 180),
                            child: Icon(Icons.rotate_left,
                                color: AppColors.thirdColor, size: fontSize + 4),
                          ),
                          SizedBox(width: horizontalSpacing),
                          TextButton(
                            onPressed: () => _rotateImage(1.0 * 3.14159 / 180),
                            child: Icon(Icons.rotate_right,
                                color: AppColors.thirdColor, size: fontSize + 4),
                          ),
                          SizedBox(width: horizontalSpacing),
                          TextButton(
                            onPressed: () => _rotateImage(90.0 * 3.14159 / 180),
                            child: Text(
                              '90',
                              style: TextStyle(color: AppColors.thirdColor, fontSize: fontSize),
                            ),
                          ),
                          SizedBox(width: horizontalSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            //-------------------------------------------------------------
            // РЕЖИМ РЕДАКТИРОВАНИЯ (полоски-ориентиры)
            //-------------------------------------------------------------
            if (_isEditing)
              Positioned(
                top: stripHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: AppColors.primaryColor,
                ),
              ),
            if (_isEditing)
              Positioned(
                top: 2 * stripHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: AppColors.primaryColor,
                ),
              ),
            if (_isEditing)
              Positioned(
                top: 3 * stripHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: AppColors.primaryColor,
                ),
              ),
            if (_isEditing)
              Positioned(
                top: availableHeight - stripHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: AppColors.primaryColor,
                ),
              ),

            //-------------------------------------------------------------
            // ТОЧКИ И РЕЗУЛЬТАТЫ ДЛЯ АКТИВНОГО СУСТАВА
            //-------------------------------------------------------------
            if (_isIndexPanelVisible)


              _isLeftActive
                  ? Stack(
                children: [
                  // Точки для левого сустава
                  if (_leftPointA1 != null)
                    Positioned(
                      left: _leftPointA1!.dx - 5,
                      top: _leftPointA1!.dy - 5,
                      child: Icon(Icons.circle, color: Colors.red, size: 10),
                    ),
                  if (_leftPointA2 != null)
                    Positioned(
                      left: _leftPointA2!.dx - 5,
                      top: _leftPointA2!.dy - 5,
                      child: Icon(Icons.circle, color: Colors.red, size: 10),
                    ),
                  if (_leftPointB1 != null)
                    Positioned(
                      left: _leftPointB1!.dx - 5,
                      top: _leftPointB1!.dy - 5,
                      child: Icon(Icons.circle, color: Colors.blue, size: 10),
                    ),
                  if (_leftPointB2 != null)
                    Positioned(
                      left: _leftPointB2!.dx - 5,
                      top: _leftPointB2!.dy - 5,
                      child: Icon(Icons.circle, color: Colors.blue, size: 10),
                    ),
                  // Результаты для левого сустава (выводим справа)
                  if (_leftDistanceA != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: ResultCardA(
                          text:
                          'Левое Расстояние A: ${_leftDistanceA?.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  if (_leftDistanceB != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 70),
                        child: ResultCardB(
                          text:
                          'Левое Расстояние B: ${_leftDistanceB!.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  if (_leftIndex != null)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 120),
                        child: ResultCardReym(
                          text: 'ИМ/Л: ${_leftIndex!.toStringAsFixed(2)}%',
                        ),
                      ),
                    ),
                ],
              )
                  : Stack(
                children: [
                  // Точки для правого сустава
                  if (_rightPointA1 != null)
                    Positioned(
                      left: _rightPointA1!.dx - 5,
                      top: _rightPointA1!.dy - 5,
                      child: Icon(Icons.album, color: Colors.red, size: 10),
                    ),
                  if (_rightPointA2 != null)
                    Positioned(
                      left: _rightPointA2!.dx - 5,
                      top: _rightPointA2!.dy - 5,
                      child: Icon(Icons.album, color: Colors.red, size: 10),
                    ),
                  if (_rightPointB1 != null)
                    Positioned(
                      left: _rightPointB1!.dx - 5,
                      top: _rightPointB1!.dy - 5,
                      child: Icon(Icons.album, color: Colors.blue, size: 10),
                    ),
                  if (_rightPointB2 != null)
                    Positioned(
                      left: _rightPointB2!.dx - 5,
                      top: _rightPointB2!.dy - 5,
                      child: Icon(Icons.album, color: Colors.blue, size: 10),
                    ),
                  // Результаты для правого сустава (выводим слева)
                  if (_rightDistanceA != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, top: 20),
                        child: ResultCardA(
                          text:
                          'Правое Расстояние A: ${_rightDistanceA?.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  if (_rightDistanceB != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, top: 70),
                        child: ResultCardB(
                          text:
                          'Правое Расстояние B: ${_rightDistanceB?.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                  if (_rightIndex != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, top: 120),
                        child: ResultCardReym(
                          text: 'ИМ/П: ${_rightIndex?.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                ],
              ),
            // Отрисовка лупы (если активна)
            if (_showMagnifier && _image != null && _isIndexPanelVisible) _buildMagnifier(screenWidth, screenHeight),

            //-------------------------------------------------------------
            // СЕТКА (если включена)
            //-------------------------------------------------------------
            if (_isGridEnabled)
              _buildGrid(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }
}

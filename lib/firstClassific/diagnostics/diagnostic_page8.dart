import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_compress/video_compress.dart';
import '../../assets/colors/app_colors.dart';
import '../../assets/data/texts/strings.dart';
import '../../services/logger.dart';
import '../../services/step_page_helper.dart';
import '../../services/temp_storage.dart';
import '../../widgets/CustomCheckboxes.dart';
import '../../widgets/CustomDialogExit.dart';
import '../../widgets/CustomHelpScreen.dart';
import '../../widgets/CustomProgressBar.dart';
import '../../widgets/CustomResultCard.dart';
import 'diagnostic_page9.dart';

class DiagnosticPage8 extends StatefulWidget {
  final int currentStep;
  final TempStorage tempStorage;

  const DiagnosticPage8({
    Key? key,
    required this.currentStep,
    required this.tempStorage,
  }) : super(key: key);

  @override
  State<DiagnosticPage8> createState() => _DiagnosticPage8State();
}

class _DiagnosticPage8State extends State<DiagnosticPage8> {
  File? _videoFile;
  VideoPlayerController? _videoPlayerController;
  FlickManager? flickManager;
  double _playbackSpeed = 1.0;
  String? _errorMessage;
  bool _videoRecorded = false; // Флаг для отслеживания, записано ли видео
  String? _selectedGaitType;

  // Добавляем список для типов походки
  List<String> _gaitTypes = [
    '1 тип',
    '2 тип',
    '3 тип',
    '4 тип',
    '5 тип',
  ];

  Future<bool> _isVideoHorizontal(File videoFile) async {
    // Получаем информацию о видео с помощью video_compress
    final info = await VideoCompress.getMediaInfo(videoFile.path);

    // Проверка на null для width и height
    if (info.width == null || info.height == null) {
      return false; // Возвращаем false, если размеры видео не определены
    }

    // Проверяем размеры: если ширина меньше высоты — видео вертикальное
    if (info.width! > info.height!) {
      return false; // Видео вертикальное
    }
    return true; // Видео горизонтальное
  }


  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      final tempVideo = File(pickedFile.path);

      // Очистка старого видео перед началом записи нового
      setState(() {
        _videoFile = tempVideo;
        _videoRecorded = false;
        _errorMessage = null;
      });

      // Если видео записано, сбросим старый контроллер и флик-менеджер
      await _disposeVideoPlayer();

      final videoController = VideoPlayerController.file(tempVideo);
      await videoController.initialize();

      // Проверка ориентации видео через метаданные
      bool isHorizontal = await _isVideoHorizontal(tempVideo);
      if (!isHorizontal) {
        setState(() {
          _videoFile = null;
          _errorMessage = 'Пожалуйста, снимите видео в горизонтальной ориентации.';
        });
        return;
      } else {
        setState(() {
          _videoRecorded = true; // Видео записано
        });
        _initializeVideoPlayer(videoController);
      }
    }
  }

  Future<void> _disposeVideoPlayer() async {
    if (_videoPlayerController != null) {
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
    if (flickManager != null) {
      flickManager?.dispose();
      flickManager = null;
    }
  }

  Future<void> _initializeVideoPlayer(VideoPlayerController videoController) async {
    _videoPlayerController = videoController;
    await _videoPlayerController?.initialize();

    setState(() {
      flickManager = FlickManager(
        videoPlayerController: _videoPlayerController!,
      );
    });
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _videoPlayerController?.setPlaybackSpeed(_playbackSpeed);
    });
  }

  void _saveDescription() {
    final description = _selectedGaitType;
    widget.tempStorage.saveData('diagnostic8.descriptionvideo', description);
    DiagnosticLogger.logDiagnostic('Тип походки', 'diagnostic8.descriptionvideo', widget.tempStorage);
  }

  void _showDescriptionDialog() {
    if (!_videoRecorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пожалуйста, запишите видео перед выбором типа походки!',
            style: TextStyle(color: AppColors.thirdColor),
          ),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Выберите тип походки'),
            titleTextStyle: TextStyle(
              color: AppColors.secondryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'TinosBold',
              fontSize: 24.0,
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _gaitTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          CustomCheckbox(
                            isSelected: _selectedGaitType == type,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value) {
                                  _selectedGaitType = type;
                                } else {
                                  _selectedGaitType = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.text2Color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Отмена', style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
              ),
              TextButton(
                onPressed: () {
                  if (_selectedGaitType != null) {
                    _saveDescription();
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiagnosticPage9(
                          currentStep: widget.currentStep + 1,
                          tempStorage: widget.tempStorage,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Пожалуйста, выберите тип походки!',
                          style: TextStyle(color: AppColors.thirdColor),
                        ),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                },
                child: Text(AppStrings.buttonCancelString, style: TextStyle(color: AppColors.text1Color, fontFamily: 'TinosBold'),),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    flickManager?.dispose();
    VideoCompress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double progressDiameter = screenWidth * 0.1;
    final double progressFontSize = screenWidth * 0.05;

    final Color textColor = AppColors.secondryColor;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showExitConfirmationDialog(context);
        return exit ?? false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
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
                        content: Text(
                          'Вы уже находитесь на данном шаге!',
                          style: TextStyle(color: AppColors.thirdColor),
                        ),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned.fill(
              top: screenHeight * 0.25,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        AppStrings.nameTitle8String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.10,
                          fontFamily: 'TinosBold',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        ResultCard(
                          text: _errorMessage!,
                        ),
                      if (flickManager != null)
                        Center(
                          child: Container(
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: FlickVideoPlayer(
                                flickManager: flickManager!,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      if (_videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Slider(
                                value: _playbackSpeed,
                                min: 0.1,
                                max: 1.0,
                                divisions: 10,
                                onChanged: (value) => _setPlaybackSpeed(value),
                                activeColor: textColor,
                                inactiveColor: Colors.grey,
                              ),
                            ),
                            Text(
                              _playbackSpeed.toStringAsFixed(1),
                              style: TextStyle(
                                color: textColor,
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      GestureDetector(
                        onTap: _pickVideo,
                        child: Container(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.065,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              "Записать видео",
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _showDescriptionDialog,
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.065,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Описать тип походки',
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: (){
                          // Сохраняем значение выбора
                          widget.tempStorage.saveData("diagnostic8.descriptionvideo", "Ребенок не может стоять, запись видео не проводилась");
                          // Получаем сохраненные данные (для проверки)
                          DiagnosticLogger.logDiagnostic('Тип походки', 'diagnostic8.descriptionvideo', widget.tempStorage);

                          // Переход на второй шаг (DiagnosticPage2)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosticPage9(
                                currentStep: widget.currentStep+1, // Передаем номер текущего шага
                                tempStorage: widget.tempStorage, // Передаем хранилище данных
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.065,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Ребенок не ходит',
                              style: TextStyle(
                                color: AppColors.thirdColor,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          int index = 7;
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
                              side: const BorderSide(
                                  width: 3.14, color: AppColors.secondryColor),
                              borderRadius: BorderRadius.circular(screenWidth * 0.08),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.buttonSpravkaString,
                              style: TextStyle(
                                color: AppColors.text1Color,
                                fontSize: screenWidth * 0.05,
                                fontFamily: 'Nexa Demo',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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

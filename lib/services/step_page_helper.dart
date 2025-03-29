import 'package:flutter/material.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page1.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page2.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page3.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page4.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page5.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page6.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page7.dart';
import 'package:neuro_pro/firstClassific/diagnostics/diagnostic_page8.dart';
import '../firstClassific/diagnostics/diagnostic_page9.dart';
import '../services/temp_storage.dart';

Widget getStepPage(int step, TempStorage tempStorage) {
  switch (step) {
    case 1:
      return DiagnosticPage1(currentStep: step, tempStorage: tempStorage);
    case 2:
      return DiagnosticPage2(currentStep: step, tempStorage: tempStorage);
    case 3:
      return DiagnosticPage3(currentStep: step, tempStorage: tempStorage);
    case 4:
      return DiagnosticPage4(currentStep: step, tempStorage: tempStorage);
    case 5:
      return DiagnosticPage5(currentStep: step, tempStorage: tempStorage);
    case 6:
      return DiagnosticPage6(currentStep: step, tempStorage: tempStorage);
    case 7:
      return DiagnosticPage7(currentStep: step, tempStorage: tempStorage);
    case 8:
      return DiagnosticPage8(currentStep: step, tempStorage: tempStorage);
    case 9:
      return DiagnosticPage9(currentStep: step, tempStorage: tempStorage);
    default:
      throw Exception('Invalid step: $step');
  }
}

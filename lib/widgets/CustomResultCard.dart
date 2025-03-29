import 'package:flutter/material.dart';
import '../assets/colors/app_colors.dart';

class ResultCard extends StatelessWidget {
  final String text;

  const ResultCard({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.errorColor, width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.errorColor,
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ResultCardA extends StatelessWidget {
  final String text;

  const ResultCardA({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: AppColors.thirdColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.errorColor, width: 2),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.errorColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
                fontFamily: 'TinosBold'
            ),
          ),
        ),
      ),
    );
  }
}

class ResultCardB extends StatelessWidget {
  final String text;

  const ResultCardB({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: AppColors.thirdColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.text2Color, width: 2),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text2Color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
                fontFamily: 'TinosBold'
            ),
          ),
        ),
      ),
    );
  }
}

class ResultCardReym extends StatelessWidget {
  final String text;

  const ResultCardReym({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: AppColors.thirdColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border4Color, width: 2),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.border4Color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'TinosBold'
            ),
          ),
        ),
      ),
    );
  }
}

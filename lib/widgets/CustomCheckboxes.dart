import 'package:flutter/material.dart';

import '../assets/colors/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    Key? key,
    required this.isSelected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        width: 41.92,
        height: 41.92,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3.46, color: AppColors.secondryColor),
            borderRadius: BorderRadius.circular(15.72),
          ),
          color: isSelected ? AppColors.border2Color : AppColors.thirdColor, // Бледно-голубой, если выбран, белый если нет
        ),
        child: null,
      ),
    );
  }
}

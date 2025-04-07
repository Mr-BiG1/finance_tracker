import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/constants.dart';

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double? verticalPadding;

  const ProfileOption({
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.verticalPadding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding ?? 16,
              horizontal: 20,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppColors.textDisabled,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

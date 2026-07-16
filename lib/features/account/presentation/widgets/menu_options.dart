import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/app/localization.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import '../../../../common/local_data.dart';

class MenuOptions extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool? showTheme;
  final bool? showroute;
  final bool? showrouteValue;
  final String? imagePath;
  final Color? textColor;
  final Color? iconColor; //  Optional icon color
  final Color? imageColor;
  final Color? iconbackground;

  const MenuOptions(
      {super.key,
      this.icon,
      required this.label,
      this.subtitle,
      required this.onTap,
      this.showTheme = false,
      this.showroute = false,
      this.showrouteValue = false,
      this.imagePath,
      this.textColor,
      this.iconColor,
      this.imageColor,
      this.iconbackground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LEFT ICON BOX
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: iconbackground ??
                    (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(
                      icon,
                      size: 20,
                      color: iconColor ??
                          (isDark ? Colors.white : const Color(0xFF475569)),
                    )
                  : (imagePath != null
                      ? Image.asset(
                          imagePath!,
                          height: 20,
                          width: 20,
                          color: imageColor ??
                              iconColor ??
                              (isDark ? Colors.white : const Color(0xFF475569)),
                          fit: BoxFit.contain,
                        )
                      : const SizedBox()),
            ),

            const SizedBox(width: 14),

            /// TITLE + SUBTITLE
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: label,
                    textStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: textColor ??
                          (isDark ? Colors.white : const Color(0xFF0F172A)),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    MyText(
                      text: subtitle!,
                      textStyle: theme.textTheme.bodySmall!.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// RIGHT SIDE ACTIONS
            if (showTheme!)
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: context.read<AccBloc>().isDarkTheme,
                  activeColor: isDark ? Colors.white : AppColors.primary,
                  activeTrackColor: isDark
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  inactiveTrackColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  activeThumbImage: const AssetImage(AppImages.sun),
                  inactiveThumbImage: const AssetImage(AppImages.moon),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) async {
                    context.read<AccBloc>().isDarkTheme = value;

                    final locale =
                        await AppSharedPreference.getSelectedLanguageCode();

                    if (!context.mounted) return;

                    context.read<LocalizationBloc>().add(
                          LocalizationInitialEvent(
                            isDark: value,
                            locale: Locale(locale),
                          ),
                        );
                  },
                ),
              ),

            if (showroute!)
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: showrouteValue!,
                  activeColor: isDark ? Colors.white : AppColors.primary,
                  activeTrackColor: isDark
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  inactiveTrackColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: null,
                ),
              ),

            if (!showTheme! && !showroute!)
              Icon(
                Icons.chevron_right_rounded,
                color:
                    isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

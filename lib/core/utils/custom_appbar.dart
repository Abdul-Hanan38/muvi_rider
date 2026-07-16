import 'package:flutter/material.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool centerTitle;
  final bool? automaticallyImplyLeading;
  final Widget? titleIcon;
  final double? titleFontSize;
  final bool showBorder;
  final Color? leadingColor;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBackTap,
    this.backgroundColor,
    this.textColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading,
    this.titleIcon,
    this.titleFontSize,
    this.showBorder = true,
    this.leadingColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTextColor =
        textColor ?? Theme.of(context).textTheme.titleLarge!.color;
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      actions: actions,
      shape: showBorder
          ? const Border(
              bottom: BorderSide(
                color: AppColors.grey, // change color here
                width: 1, // thickness
              ),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titleIcon != null) ...[
                titleIcon!,
                const SizedBox(width: 8),
              ],
              MyText(
                text: title,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: resolvedTextColor,
                      fontSize: titleFontSize ??
                          Theme.of(context).textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            MyText(
              text: subtitle!,
              textStyle: TextStyle(
                fontSize: 12,
                color: resolvedTextColor!.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
      centerTitle: centerTitle,
      leading: (automaticallyImplyLeading != null && automaticallyImplyLeading!)
          ? IconButton(
              icon: Icon(Icons.arrow_back,
                  color: leadingColor ?? Theme.of(context).hintColor),
              onPressed: onBackTap ?? () => Navigator.of(context).pop(),
            )
          : const SizedBox(),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (subtitle != null ? 10 : 0));
}

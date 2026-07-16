import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_text.dart';

class FareBreakup extends StatelessWidget {
  final String text;
  final String price;
  final dynamic textcolor;
  final dynamic pricecolor;
  final dynamic fntweight;
  final dynamic showBorder;
  final dynamic padding;
  final IconData? icon;

  const FareBreakup({
    super.key,
    required this.text,
    required this.price,
    this.textcolor,
    this.pricecolor,
    this.fntweight,
    this.showBorder,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paddingValue = EdgeInsets.symmetric(
      vertical: padding ?? size.width * 0.03,
    );

    // Modern card/row colors matching the mockup
    final defaultLabelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final defaultPriceColor = isDark ? Colors.white : const Color(0xFF1E293B);

    Widget content = Padding(
      padding: paddingValue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 16,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: MyText(
                    text: text,
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 14,
                          fontWeight: fntweight ?? FontWeight.w500,
                          color: textcolor ?? defaultLabelColor,
                        ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MyText(
            text: price,
            textAlign: TextAlign.end,
            textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 14,
                  fontWeight: fntweight ?? FontWeight.w600,
                  color: pricecolor ?? defaultPriceColor,
                ),
          ),
        ],
      ),
    );

    if (showBorder == null || showBorder == true) {
      return DottedBorder(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        strokeWidth: 1,
        dashPattern: const [4, 3],
        padding: EdgeInsets.zero,
        customPath: (size) {
          final path = Path();
          path.moveTo(0, size.height);
          path.lineTo(size.width, size.height);
          return path;
        },
        child: content,
      );
    } else if (showBorder == 'top') {
      return DottedBorder(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        strokeWidth: 1,
        dashPattern: const [4, 3],
        padding: EdgeInsets.zero,
        customPath: (size) {
          final path = Path();
          path.moveTo(0, 0);
          path.lineTo(size.width, 0);
          return path;
        },
        child: content,
      );
    } else {
      return content;
    }
  }
}

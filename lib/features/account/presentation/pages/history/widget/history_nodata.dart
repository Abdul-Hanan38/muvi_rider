import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';

class HistoryNodataWidget extends StatelessWidget {
  const HistoryNodataWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Retrieve the current tab from the bloc if available
    int selectedTab = 0;
    try {
      selectedTab = context.read<AccBloc>().selectedHistoryType;
    } catch (_) {}

    String title = '';
    String subtitle = '';
    String tipText = '';

    if (selectedTab == 0) {
      title = AppLocalizations.of(context)!.noCompletedRidesText;
      subtitle = AppLocalizations.of(context)!.noCompletedRidesTextSubTitle;
      tipText = AppLocalizations.of(context)!.noCompletedRidesTextTipText;
    } else if (selectedTab == 1) {
      title = AppLocalizations.of(context)!.noUpcomingRidesText;
      subtitle = AppLocalizations.of(context)!.noUpcomingRidesTextSubTitle;
      tipText = AppLocalizations.of(context)!.noUpcomingRidesTextTipText;
    } else {
      title = AppLocalizations.of(context)!.noCancelledRidesText;
      subtitle = AppLocalizations.of(context)!.noCancelledRidesTextSubTitle;
      tipText = AppLocalizations.of(context)!.noCancelledRidesTextTipText;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.width * 0.025),
            // Illustration Image
            Image.asset(
              AppImages.historyNoDataImage,
              height: size.width * 0.75,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),

            // Title
            MyText(
              text: title,
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            MyText(
              text: subtitle,
              maxLines: 2,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            // Tip Box Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF131C2E) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFDBEAFE),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon Circle Container
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tip Copy
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.historyTipText,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          text: tipText,
                          maxLines: 2,
                          textStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

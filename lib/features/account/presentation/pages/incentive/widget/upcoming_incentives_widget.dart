import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/incentive_model.dart';

class ShowUpcomingIncentivesWidget extends StatelessWidget {
  final BuildContext cont;
  final List<UpcomingIncentive> upcomingIncentives;

  const ShowUpcomingIncentivesWidget({
    super.key,
    required this.cont,
    required this.upcomingIncentives,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardBg =
              isDark ? const Color(0xFF131E35) : const Color(0xFFF8FAFC);
          final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
          final textMutedColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          final incentives = context
              .read<AccBloc>()
              .selectedIncentiveHistory!
              .upcomingIncentives;

          return ListView.separated(
            padding: EdgeInsets.only(
                top: size.width * 0.05, bottom: size.height * 0.05),
            itemCount: incentives.length + 1,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == incentives.length) {
                // Card E: "Keep going!" Card
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1E36)
                        : const Color(0xFFEFF6FF),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E2E4A)
                          : const Color(0xFFDBEAFE),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2E4A)
                              : const Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.info_outline_rounded,
                          color:
                              isDark ? AppColors.secondary : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.keepGoingText,
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .incentiveCompleteMoreRidesText,
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: textMutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.celebration_rounded,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        size: 32,
                      ),
                    ],
                  ),
                );
              }

              final item = incentives[index];
              final isCompleted = item.isCompleted;

              if (isCompleted) {
                // Card B: Completed Target Card
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.borderColors,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1B3D2B)
                              : const Color(0xFFEFFDF4),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: isDark
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFF16A34A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text:
                                  "${AppLocalizations.of(context)!.completeText} ${item.rideCount}",
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDarkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .acheivedTargetText,
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: textMutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      MyText(
                        text:
                            "${userData!.currencySymbol} ${item.incentiveAmount}",
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Card D: Missed Target Card (with dotted border around check circle replacement)
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.borderColors,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      DottedBorder(
                        color: isDark
                            ? const Color(0xFFEF4444).withOpacity(0.5)
                            : const Color(0xFFEF4444).withOpacity(0.4),
                        strokeWidth: 1.5,
                        dashPattern: const [4, 3],
                        borderType: BorderType.Circle,
                        child: Container(
                          width: 37,
                          height: 37,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? const Color(0xFFF87171)
                                : const Color(0xFFDC2626),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text:
                                  "${AppLocalizations.of(context)!.completeText} ${item.rideCount}",
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDarkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .missedTargetText,
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      MyText(
                        text:
                            "${userData!.currencySymbol} ${item.incentiveAmount}",
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF87171)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

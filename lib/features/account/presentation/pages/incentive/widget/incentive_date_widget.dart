import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../application/acc_bloc.dart';

class IncentiveDateWidget extends StatelessWidget {
  final BuildContext cont;
  const IncentiveDateWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final bloc = context.read<AccBloc>();

          final uniqueDates =
              bloc.incentiveDates.fold<List<dynamic>>([], (list, item) {
            bloc.formatDateBasedOnIndex(
              item.date,
              bloc.choosenIncentiveData,
            );
            if (!list.any((e) => e.date == item.date && e.day == item.day)) {
              list.add(item);
            }
            return list;
          });

          return SizedBox(
            height: size.width * 0.22,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: bloc.incentiveScrollController,
              itemCount: uniqueDates.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: size.width * 0.038),
              itemBuilder: (context, index) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final dateItem = uniqueDates[index];
                final incentiveDate = dateItem.date;
                final day = dateItem.day;

                final formattedDate = bloc.formatDateBasedOnIndex(
                  incentiveDate,
                  bloc.choosenIncentiveData,
                );

                final apiDate = bloc.choosenIncentiveData == 0
                    ? DateFormat("dd-MMM-yy").parse(incentiveDate)
                    : DateFormat('dd').parse(formattedDate);

                final today = DateTime.now();
                final isAfterToday = bloc.choosenIncentiveData == 0
                    ? apiDate.isAfter(today)
                    : false;

                final isSelectedDate = bloc.selectedDate == formattedDate;

                final cardBg =
                    isDark ? const Color(0xFF131E35) : const Color(0xFFF8FAFC);
                final textDarkColor =
                    isDark ? Colors.white : const Color(0xFF1F2937);
                final textMutedColor =
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
                final primaryColor =
                    isDark ? AppColors.secondary : AppColors.primary;

                return InkWell(
                  onTap: isAfterToday && bloc.choosenIncentiveData == 0
                      ? null
                      : () {
                          bloc.selectedDate = formattedDate;
                          bloc.add(
                            SelectIncentiveDateEvent(
                              selectedDate: formattedDate,
                              isSelected: true,
                              choosenIndex: bloc.choosenIncentiveData,
                            ),
                          );
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: size.width * 0.15,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelectedDate
                          ? (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEFF6FF).withOpacity(0.5))
                          : cardBg,
                      border: Border.all(
                        color:
                            isSelectedDate ? primaryColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          text: day,
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isAfterToday && bloc.choosenIncentiveData == 0
                                    ? Theme.of(context).disabledColor
                                    : isSelectedDate
                                        ? primaryColor
                                        : textMutedColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text: formattedDate,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                isAfterToday && bloc.choosenIncentiveData == 0
                                    ? Theme.of(context).disabledColor
                                    : isSelectedDate
                                        ? primaryColor
                                        : textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelectedDate
                                ? primaryColor
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class DriverPerformDetailsWidget extends StatelessWidget {
  final BuildContext cont;
  final DriverDashboardArguments args;
  const DriverPerformDetailsWidget(
      {super.key, required this.cont, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardBgColor =
              isDark ? const Color(0xFF131E35) : const Color(0xFFFFFFFF);
          final borderColor =
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
          final primaryText =
              isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
          final secondaryText =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Container(
            width: size.width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: borderColor),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(args.profile),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          text: args.driverName,
                          textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryText),
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          text: context
                              .read<AccBloc>()
                              .driverPerformanceData!
                              .completedRequests,
                          textStyle: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                          ),
                        )
                      ],
                    )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    // Booking
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(height: 6),
                            MyText(
                              text: context
                                  .read<AccBloc>()
                                  .driverPerformanceData!
                                  .totalTrips
                                  .toString(),
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: AppLocalizations.of(context)!.booking,
                              textStyle: TextStyle(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Distance
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.speed_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(height: 6),
                            MyText(
                              text:
                                  '${context.read<AccBloc>().driverPerformanceData!.totalDistance} Km',
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: AppLocalizations.of(context)!.distance,
                              textStyle: TextStyle(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Earnings
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(height: 6),
                            MyText(
                              text:
                                  '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.totalEarnings}',
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: AppLocalizations.of(context)!.earnings,
                              textStyle: TextStyle(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

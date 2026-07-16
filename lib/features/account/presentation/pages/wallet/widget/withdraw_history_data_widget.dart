import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class WithdrawHistoryDataWidget extends StatelessWidget {
  final BuildContext cont;
  final List withdrawHistoryList;
  const WithdrawHistoryDataWidget(
      {super.key, required this.cont, required this.withdrawHistoryList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return withdrawHistoryList.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: withdrawHistoryList.length,
                    separatorBuilder: (context, index) => Divider(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = withdrawHistoryList[index];
                      final String status = (item['status'] ?? '').toString();
                      final String createdAt =
                          (item['created_at'] ?? '').toString();
                      final String amount =
                          (item['requested_amount'] ?? '').toString();
                      final bool isApproved =
                          status.toLowerCase() == 'approved';
                      final bool isRequested =
                          status.toLowerCase() == 'requested';

                      // Determine icon, colors
                      Color badgeBgColor;
                      Color badgeIconColor;
                      IconData statusIcon;
                      Color statusTextColor;

                      if (isApproved) {
                        badgeBgColor = isDark
                            ? const Color(0xFF064E3B)
                            : const Color(0xFFDCFCE7);
                        badgeIconColor = isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF15803D);
                        statusIcon = Icons.check;
                        statusTextColor = isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF16A34A);
                      } else if (isRequested) {
                        badgeBgColor = isDark
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFFDBEAFE);
                        badgeIconColor = isDark
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF1D4ED8);
                        statusIcon = Icons.access_time_rounded;
                        statusTextColor =
                            isDark ? AppColors.secondary : AppColors.primary;
                      } else {
                        badgeBgColor = isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9);
                        badgeIconColor = textSecondary;
                        statusIcon = Icons.help_outline;
                        statusTextColor = textPrimary;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left Status Icon Circle
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                statusIcon,
                                color: badgeIconColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Middle Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: status,
                                    textStyle: TextStyle(
                                      color: statusTextColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  MyText(
                                    text: createdAt,
                                    textStyle: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right Amount Text
                            MyText(
                              text: '${userData!.currencySymbol}$amount',
                              textStyle: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.walletNoData,
                          height: size.width * 0.6,
                          width: 200,
                        ),
                        const SizedBox(height: 16),
                        MyText(
                          text: AppLocalizations.of(context)!.noPaymentHistory,
                          textStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          text: AppLocalizations.of(context)!.bookingRideText,
                          textStyle: TextStyle(
                            color: textSecondary.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}

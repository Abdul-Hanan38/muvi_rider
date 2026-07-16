import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class TripEarningsWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripEarningsWidget({
    super.key,
    required this.cont,
    required this.arg,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium styling colors
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final headerTextColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          if (arg.historyData.requestBill == null) {
            return const SizedBox();
          }

          final bill = arg.historyData.requestBill.data;
          final isCompleted = arg.historyData.isCompleted == 1;
          final isBidRide = arg.historyData.isBidRide == 1;

          final totalFareText = isBidRide
              ? '${bill.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
              : isCompleted
                  ? '${bill.requestedCurrencySymbol} ${bill.totalAmount}'
                  : '${bill.requestedCurrencySymbol} ${bill.requestEtaAmount}';

          return Container(
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: cardBorder),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.earnings,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: headerTextColor,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F291E)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.trending_up,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.04),

                // Total Fare row
                _buildEarningsRow(
                  context,
                  label: AppLocalizations.of(context)!.totalFare,
                  value: totalFareText,
                  isDark: isDark,
                  showBorder: true,
                ),

                // Tips row (if any)
                if (bill.driverTips != "0")
                  _buildEarningsRow(
                    context,
                    label: AppLocalizations.of(context)!.tips,
                    value: '${bill.requestedCurrencySymbol} ${bill.driverTips}',
                    isDark: isDark,
                    showBorder: true,
                  ),

                // Customer Convenience Fee row
                _buildEarningsRow(
                  context,
                  label: AppLocalizations.of(context)!.customerConvenienceFee,
                  value:
                      '-${bill.requestedCurrencySymbol} ${bill.adminCommision}',
                  isDark: isDark,
                  isNegative: true,
                  showBorder: true,
                ),

                // Commission row
                _buildEarningsRow(
                  context,
                  label: AppLocalizations.of(context)!.commission,
                  value:
                      '-${bill.requestedCurrencySymbol} ${bill.adminCommisionFromDriver}',
                  isDark: isDark,
                  isNegative: true,
                  showBorder: true,
                ),

                // Tax row
                _buildEarningsRow(
                  context,
                  label: AppLocalizations.of(context)!.taxText,
                  value: '-${bill.requestedCurrencySymbol} ${bill.serviceTax}',
                  isDark: isDark,
                  isNegative: true,
                  showBorder: true,
                ),

                // Promo Discount row (if any)
                if (bill.promoDiscount != 0)
                  _buildEarningsRow(
                    context,
                    label: AppLocalizations.of(context)!.discountFromWallet,
                    value:
                        '${bill.requestedCurrencySymbol} ${bill.promoDiscount}',
                    isDark: isDark,
                    isPositive: true,
                    showBorder: false,
                  ),

                SizedBox(height: size.width * 0.04),

                // Trip Earnings Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F291E)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.tripEarnings,
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF047857),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF065F46).withOpacity(0.4)
                                  : const Color(0xFFD1FAE5),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFA7F3D0),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(width: 12),
                          MyText(
                            text:
                                '${bill.requestedCurrencySymbol} ${bill.driverCommision}',
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningsRow(
    BuildContext context, {
    required String label,
    required String value,
    required bool isDark,
    bool isNegative = false,
    bool isPositive = false,
    bool showBorder = true,
  }) {
    final size = MediaQuery.sizeOf(context);
    final defaultLabelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final defaultPriceColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final priceColor = isNegative
        ? const Color(0xFFEF4444)
        : isPositive
            ? const Color(0xFF10B981)
            : defaultPriceColor;

    Widget content = Padding(
      padding: EdgeInsets.symmetric(vertical: size.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: MyText(
              text: label,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: defaultLabelColor,
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 12),
          MyText(
            text: value,
            textAlign: TextAlign.end,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: priceColor,
            ),
          ),
        ],
      ),
    );

    if (showBorder) {
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
    }

    return content;
  }
}

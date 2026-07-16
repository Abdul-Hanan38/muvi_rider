import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import 'fare_breakup.dart';

class TripFarebreakupWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripFarebreakupWidget({
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
          final isCancelled = arg.historyData.isCancelled == 1;
          final isCompleted = arg.historyData.isCompleted == 1;

          if (!isCancelled && !isCompleted) {
            return const SizedBox();
          }

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
                      text: isCancelled
                          ? AppLocalizations.of(context)!.cancelled
                          : AppLocalizations.of(context)!.fareBreakup,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isCancelled ? AppColors.red : headerTextColor,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 18,
                          color:
                              isDark ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.04),

                // Bid Ride Layout (Special Case)
                if (arg.historyData.isBidRide == 1 && !isCancelled)
                  Center(
                    child: Column(
                      children: [
                        _buildPaymentOptBadge(context, isDark),
                        const SizedBox(height: 12),
                        MyText(
                          text: (arg.historyData.requestBill == null)
                              ? '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
                              : '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                          textStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: headerTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Standard Fare Breakup Rows
                if (!isCancelled &&
                    arg.historyData.requestBill != null &&
                    arg.historyData.isBidRide != 1) ...[
                  if (arg.historyData.requestBill.data.basePrice != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.navigation_outlined,
                      text:
                          "${AppLocalizations.of(context)!.basePrice} (${arg.historyData.requestBill!.data.baseDistance} ${arg.historyData.requestBill!.data.unit})",
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.basePrice}',
                    ),
                  if (arg.historyData.requestBill.data.distancePrice != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.alt_route_outlined,
                      text:
                          "${AppLocalizations.of(context)!.distancePrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.pricePerDistance} x ${arg.historyData.requestBill!.data.calculatedDistance} ${arg.historyData.requestBill!.data.unit})",
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.distancePrice}',
                    ),
                  if (arg.historyData.requestBill.data.timePrice != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.access_time_outlined,
                      text:
                          "${AppLocalizations.of(context)!.timePrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.pricePerTime} x ${arg.historyData.requestBill!.data.totalTime})",
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.timePrice}',
                    ),
                  if (arg.historyData.requestBill.data.waitingCharge != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.hourglass_empty_outlined,
                      text:
                          "${AppLocalizations.of(context)!.waitingPrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.waitingChargePerMin} x ${arg.historyData.requestBill!.data.calculatedWaitingTime} mins)",
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.waitingCharge}',
                    ),
                  if (arg.historyData.requestBill.data.adminCommision != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.shopping_bag_outlined,
                      text: AppLocalizations.of(context)!.convFee,
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommision}',
                    ),
                  if (arg.historyData.requestBill.data.promoDiscount != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.local_offer_outlined,
                      text: AppLocalizations.of(context)!.discount,
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.promoDiscount}',
                    ),
                  if (arg.historyData.requestBill.data
                              .additionalChargesAmount !=
                          0 &&
                      arg.historyData.requestBill.data
                              .additionalChargesReason !=
                          null)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.add_circle_outline_rounded,
                      text: AppLocalizations.of(context)!.additionalCharges,
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.additionalChargesAmount}',
                    ),
                  if (arg.historyData.requestBill.data.cancellationFee != 0.0 &&
                      arg.historyData.requestBill.data.cancellationFee != 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.cancel_outlined,
                      text: AppLocalizations.of(context)!.cancellationFee,
                      price:
                          '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.cancellationFee}',
                    ),
                  if (arg.historyData.requestBill.data.airportSurgeFee != 0 &&
                      arg.historyData.requestBill.data.airportSurgeFee != '' &&
                      arg.historyData.transportType == 'taxi' &&
                      arg.historyData.isBidRide == 0)
                    FareBreakup(
                      showBorder: true,
                      icon: Icons.airplanemode_active_outlined,
                      text: AppLocalizations.of(context)!.airportSurgeFee,
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.airportSurgeFee}',
                    ),
                  FareBreakup(
                    showBorder: false,
                    icon: Icons.receipt_outlined,
                    text: AppLocalizations.of(context)!.taxes,
                    price:
                        '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.serviceTax}',
                  ),
                  if (arg.historyData.requestBill.data.preferencePriceTotal !=
                      0)
                    FareBreakup(
                      showBorder: false,
                      icon: Icons.star_outline_rounded,
                      text: AppLocalizations.of(context)!.preferenceTotal,
                      price:
                          '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.preferencePriceTotal}',
                    ),

                  SizedBox(height: size.width * 0.04),

                  // Customer Pays Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.customerPays,
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1E40AF),
                          ),
                        ),
                        Row(
                          children: [
                            _buildPaymentOptBadge(context, isDark),
                            const SizedBox(width: 12),
                            MyText(
                              text:
                                  '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOptBadge(BuildContext context, bool isDark) {
    final String label = (arg.historyData.paymentOpt == '1')
        ? AppLocalizations.of(context)!.cash
        : (arg.historyData.paymentOpt == '2')
            ? AppLocalizations.of(context)!.wallet
            : (arg.historyData.paymentOpt == '0')
                ? AppLocalizations.of(context)!.card
                : '';

    final IconData iconData = (arg.historyData.paymentOpt == '1')
        ? Icons.local_atm_outlined
        : (arg.historyData.paymentOpt == '2')
            ? Icons.account_balance_wallet_outlined
            : Icons.credit_card_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFBFDBFE),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            text: label,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E40AF),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            iconData,
            size: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E40AF),
          ),
        ],
      ),
    );
  }
}

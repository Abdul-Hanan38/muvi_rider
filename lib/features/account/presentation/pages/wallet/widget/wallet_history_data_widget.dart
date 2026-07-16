import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/walletpage_model.dart';

class WalletHistoryDataWidget extends StatelessWidget {
  final BuildContext cont;
  final List<WalletHistoryData> walletHistoryList;
  const WalletHistoryDataWidget(
      {super.key, required this.cont, required this.walletHistoryList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final iconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);
    final iconColor = isDark ? AppColors.secondary : AppColors.primary;

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          if (walletHistoryList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.walletNoDataImage,
                      height: size.width * 0.6,
                      width: 200,
                    ),
                    const SizedBox(height: 10),
                    MyText(
                      text: AppLocalizations.of(context)!.noPaymentHistory,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).disabledColor),
                    ),
                    MyText(
                      text: AppLocalizations.of(context)!.bookingRideText,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: walletHistoryList.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: dividerColor,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final item = walletHistoryList[index];
              final isDebit = item.isCredit == 0;
              final currency =
                  context.read<AccBloc>().walletResponse?.currencySymbol ?? '';
              final amountText = NumberFormat.currency(
                locale: 'en_IN',
                symbol: '',
                decimalDigits: 2,
              ).format(double.tryParse(item.amount.toString()) ?? 0);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular icon container
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: (item.remarks == 'Money Deposited')
                          ? Image.asset(
                              AppImages.moneyDeposited,
                              fit: BoxFit.contain,
                              width: 20,
                              color: iconColor,
                            )
                          : Image.asset(
                              AppImages.moneyTransfered,
                              fit: BoxFit.contain,
                              width: 20,
                              color: iconColor,
                            ),
                    ),
                    const SizedBox(width: 14),
                    // Remarks & Date/Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                            text: item.remarks,
                            textStyle: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            text: item.createdAt,
                            textStyle: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Amount Text
                    MyText(
                      text: '${isDebit ? '- ' : '+ '}$currency $amountText',
                      textStyle: TextStyle(
                        color: isDebit
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
